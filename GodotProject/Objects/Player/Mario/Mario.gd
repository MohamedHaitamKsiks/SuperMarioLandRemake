extends KinematicBody2D

#import object to instance
const WaveEffect = preload("res://Objects/Particles/WaveEffect/WaveEffect.tscn")
const Cappy = preload("res://Objects/Cappy/Cappy.tscn")
const Coin = preload("res://Objects/Items/Coin/Coin.tscn")

#signals
# warning-ignore:unused_signal
signal shake_camera(power,time,period)
signal get_back_cappy()
signal finish_level()


#const
const GRAVITY = 10
const ACC = 20
const MAX_HSPEED = 160
const MAX_VSPEED = 500
const JUMP_FORCE = 190
const JUMP_ACC = 5
const FLOOR = Vector2(0,-1)


#variables
#modes
var with_hat = true
var sprite_with_hat = "hat_"
var throwing = false
var cappy_jump = false
#teleport
var teleport = false
var teleport_angle = 0
#mouvements
var velocity = Vector2(0,0)
var ground = true
#jumping
var jump = true
var wall_jump = false
var climbing = false
var jump_flip = false
var jump_charge = 0
#dive
var dive = false
#down/smash
var down = false
var prepare_smash = false
var smash = false
#run
var sprint = false
var turning = false
var max_speed = false

#hit
var hit = false
var can_hit = true
var is_visible = true
#start
var start = true
var can_move = true
#end level
var slide = false
var finish = false
var finish_dance = false
#camera
var camera_period = 1
var camera_power = 0
var camera_time = 1
var camera_direction = 0
var time = 0
var charge_time = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.position.y = 100
	$CameraPosition.position.x = 50

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	on_floor()
	if not (start or hit or prepare_smash or throwing or slide or finish or teleport or not can_move):
		velocity = mouvement_manager(velocity)
		if throwing:
			velocity = Vector2(0,0)
	if finish :
		finish_cinematic()
	else :
		sprites_manager(velocity)
	
	if slide and not ground:
		slide_coins()
	
	if max_speed or hit:
		$AnimatedSprite.modulate = Color(1.0 , 1.0 - 0.7*exp(-4*charge_time) , 1.0 - 0.7*exp(-4*charge_time) , 1.0)
	elif down and ground and jump_charge == 100:
		$AnimatedSprite.modulate = Color(1.0 , 1.0 - 0.7*abs(cos(-4*charge_time)) , 1.0 - 0.7*abs(cos(-4*charge_time)) , 1.0)	
	else :
		$AnimatedSprite.modulate = Color(1.0,1.0,1.0,1.0)
		
		
	camera_manager(velocity)
	dust_particles()
	
	velocity = move_and_slide_with_snap(velocity, -FLOOR ,FLOOR)
	
	time += delta
	charge_time += delta


####functions#####

##on floor##
func on_floor():
	if is_on_floor() :
		if not ground :
			turning = false
			if smash:
				smash = false
				start_camera_shake(16 ,0.3,0.1)
				wave_effect(1)
				$SFXSmash.play()
				$DustParticles.emitting = true
			else:
				$SFXFootStep.play()
				if finish:
					finish_dance = not finish_dance
					
		jump = false
		jump_flip = false
		climbing = false
		wall_jump = false
		ground = true
		cappy_jump = false
	else :
		if ground and turning:
			turning = false
			if jump :
				$AnimatedSprite.play(sprite_with_hat + "jump")
				return
			$AnimatedSprite.play(sprite_with_hat + "fall")
		ground = false


##mouvements##
# warning-ignore:shadowed_variable
func mouvement_manager(velocity):
	#blinking effects
	$AnimatedSprite.visible = (is_visible and not can_hit) or can_hit

	#basic mouvements
	var direction = int(Input.is_action_pressed("right"))-int(Input.is_action_pressed("left"))
	
	var acceleration = ACC * direction * int(not (wall_jump or down or smash or dive) ) * (1 - int(sprint and abs(velocity.x) > MAX_HSPEED and direction * velocity.x >= 0 and ground)*0.7)#acceleration
	var deceleration = ACC * sign(velocity.x) * int(direction == 0 or down or smash or dive) * int(not wall_jump) * int(not dive or ground) * (1 - 0.4 * int(dive and ground)) * (0.5 + 0.5 * int(ground))#deceleration
	
	if sprint and not ground and direction * velocity.x > 0 and direction != 0 and abs(velocity.x) > MAX_HSPEED:
		acceleration = 0
		deceleration = 0
	
	velocity.x += acceleration
	velocity.x -= deceleration
	
	if abs(velocity.x) > MAX_HSPEED * ( 1 + int(sprint)) and not dive :#max speed
		velocity.x = MAX_HSPEED * ( 1 + int(sprint)) * sign(velocity.x)
		if sprint and not max_speed:
			max_speed = true
			charge_time = 0
			start_camera_shake(6,0.4,0.1)
			$SFXMaxSpeed.play()
	

	if abs(velocity.x) < ACC :
		velocity.x = 0

	if not sprint or abs(velocity.x) < 2*MAX_HSPEED:
		max_speed = false

	#sprining
	sprint = Input.is_action_pressed("gameplay_sprint")

	#down
	if Input.is_action_pressed("gameplay_down") and ground and not smash :
		if not down :
			$SFXCappy.play()
			jump_charge = 0
		down = true
		$HitBox.position.y = 16
		if jump_charge > 100:
			jump_charge = 100
			$SFXCharge.play()
			start_camera_shake(4,0.4,0.1)
			charge_time = 0
		elif jump_charge < 100:
			jump_charge += 3
	else :
		down = false
		$HitBox.position.y = 0
		

	#smash
	if not (ground or smash or prepare_smash) and Input.is_action_just_pressed("gameplay_down"):
		$SFXCappy.play()
		prepare_smash = true
		velocity = Vector2(0,0)
		jump_flip = false
		climbing = false
	$ItemCollision.position.y = 16* velocity.y / MAX_VSPEED

	#climbing
	##ray cast to wall
	if $AnimatedSprite.flip_h:
		$CanClimbRayCastTop.cast_to.x = -12
		$CanClimbRayCastBot.cast_to.x = -12
		$ThrowPosition2D.position.x = -24
	else :
		$CanClimbRayCastTop.cast_to.x = 12
		$CanClimbRayCastBot.cast_to.x = 12
		$ThrowPosition2D.position.x = 24
	var cast_wall = $CanClimbRayCastTop.is_colliding() and $CanClimbRayCastBot.is_colliding()
	#if on wall => climb
	if is_on_wall() and (not ground and not dive) and cast_wall and velocity.y > 0:
		climbing = true
		cappy_jump = false
		jump_flip = false
		jump = false
		turning = false
		wall_jump = false
	elif (ground or dive) or not cast_wall:
		climbing = false
	
	if not $SFXClimbing.playing and (climbing or (dive and ground)):
		$SFXClimbing.play()
	if not (climbing or dive) and $SFXClimbing.playing:
		$SFXClimbing.stop()


	#walljump
	if Input.is_action_just_pressed("gameplay_jump") and climbing :
		velocity.y = -JUMP_FORCE*1.5
		velocity.x = 250 * (int($AnimatedSprite.flip_h) - int(not $AnimatedSprite.flip_h))
		$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
		wall_jump = true
		climbing = false
		turning = false
		$SFXWalljump.play()
		$SFXJump.play()

	#jump
	if Input.is_action_just_pressed("gameplay_jump") and ground and not (throwing) :
		velocity.y = -JUMP_FORCE
		jump = true
		turning = false
		if dive:
			velocity.x = -250 * (int($AnimatedSprite.flip_h) - int(not $AnimatedSprite.flip_h))
			wall_jump = true
			jump_flip = true
			dive = false
		elif down:
			jump_flip = true
			velocity.y = - 1.3 * JUMP_FORCE * jump_charge / 100
			if jump_charge == 100:
				$SFXJumpFlip.play()
		$SFXJump.play()
	##long jump
	if Input.is_action_pressed("gameplay_jump") and jump and not cappy_jump:
		velocity.y -= JUMP_ACC
	#stop jumping
	if velocity.y >0 :
		jump = false
		wall_jump = false
		jump_flip = false
		$AttackBox/CollisionShape2D.disabled = false
	else :
		$AttackBox/CollisionShape2D.disabled = true
	
	#dive
	if Input.is_action_just_pressed("gameplay_dive") and not (dive or climbing or hit) and not ($CanClimbRayCastBot.is_colliding() or $CanClimbRayCastTop.is_colliding()):
		reset_variables()
		dive = true
		velocity.x = 1.5 * MAX_HSPEED * (-int($AnimatedSprite.flip_h) + int(not $AnimatedSprite.flip_h))
		velocity.y = -0.7 * JUMP_FORCE
		$SFXDive.play()
		start_camera_shake(8,0.2,0.1)
	#dive collide with wall	
	if dive and is_on_wall():
		reset_variables()
		velocity = Vector2(0,0)
		start_camera_shake(8,0.3,0.1)
		get_damage($ThrowPosition2D,0)
	#
	if dive and velocity.x == 0:
		dive = false
	#

	#Throw Cappy
	if with_hat and not (climbing or hit or smash or dive or cappy_jump) and Input.is_action_just_pressed("gameplay_throwcappy") and not $CanClimbRayCastBot.is_colliding():
		with_hat = false
		throwing = true
		jump = false
		wall_jump = false
		jump_flip = false
		dive = false
		velocity = Vector2(0,0)
		$SFXThrowCappy.play()
		$SFXCappy.play()

	# gravity
	$AttackBox.position.y = 4*int(velocity.y>0)
	if velocity.y <= MAX_VSPEED * (1 - int(climbing) * 0.9):
		velocity.y += GRAVITY
	else :
		velocity.y = MAX_VSPEED * (1 - int(climbing) * 0.9)

	return velocity


#get back cappy
func _on_Mario_get_back_cappy():
	with_hat = true
	sprite_with_hat = "hat_"
	$SFXCappy.play()


##Animed Sprite##
#
#sprite
func sprites_manager(velocity):
	
	if dive:
		var velovity_normal = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
		if velocity.x < 0:
			$AnimatedSprite.rotation =  atan2(0.5*velocity.y / velovity_normal , velocity.x / velovity_normal) + PI
		else :
			$AnimatedSprite.rotation =  atan2(0.5*velocity.y / velovity_normal , velocity.x / velovity_normal)
	elif jump_flip:
		$AnimatedSprite.rotation += 0.5 * (int(not $AnimatedSprite.flip_h) - int($AnimatedSprite.flip_h))
	else :
		$AnimatedSprite.rotation = 0
	
	#teleport or start
	if teleport :
		$AnimatedSprite.position.x += 0.5 * cos(teleport_angle)
		$AnimatedSprite.position.y += 0.5 * sin(teleport_angle)
		z_index = -100
	elif start:
		$AnimatedSprite.position.y -= 0.5
		if int($AnimatedSprite.position.y) == 32 and not $SFXStart.playing:
			$SFXStart.play()
		if $AnimatedSprite.position.y <= 0:
			$AnimatedSprite.position.y = 0
			start = false
			turning = false
		z_index = -100
	else:
		$AnimatedSprite.position = Vector2(0,0)
		z_index = 0
		
	#falling stretch
	
	$AnimatedSprite.scale.y = 1 + (velocity.y / MAX_VSPEED) * 0.2 * int(not climbing)
	$AnimatedSprite.scale.x = 1 - abs(velocity.y / MAX_VSPEED) * 0.2 * int(not climbing)
	
	$AnimatedSprite.speed_scale = 1

	#turning
	if ((velocity.x > 0 and $AnimatedSprite.flip_h) or (velocity.x < 0 and not $AnimatedSprite.flip_h)) and not(turning or climbing or wall_jump or hit or jump_flip):
		$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
		turning = true
		climbing = false
		if ground :
			$AnimatedSprite.play(sprite_with_hat + "turn")
		else :
			$AnimatedSprite.play(sprite_with_hat + "turn_air")


	#sprite
	
	if throwing:
		$AnimatedSprite.play("hat_throw_cappy")
	elif dive :
		$AnimatedSprite.play(sprite_with_hat + "dive")
	elif hit :
		$AnimatedSprite.speed_scale = 1
		$AnimatedSprite.play(sprite_with_hat + "hit")

	else :
		if not turning:
			#on ground
			if ground :
				if is_on_wall() :
					$AnimatedSprite.play(sprite_with_hat + "wall_walk")

				else :
					if down :
						$AnimatedSprite.play(sprite_with_hat + "down")
					else :
						var direction = int(Input.is_action_pressed("right"))-int(Input.is_action_pressed("left"))
						
						if velocity.x * direction < 0:
							if not "break" in $AnimatedSprite.animation and abs(velocity.x) > MAX_HSPEED:
								$SFXBreak.play()
							$AnimatedSprite.play(sprite_with_hat + "break")
							
						else :
							if velocity.x == 0:
								$AnimatedSprite.play(sprite_with_hat + "stand")
							elif abs(velocity.x) < 2 * MAX_HSPEED:
								$AnimatedSprite.play(sprite_with_hat + "run_with_smears")
								$AnimatedSprite.speed_scale = abs(velocity.x)/MAX_HSPEED
							else :
								$AnimatedSprite.play(sprite_with_hat + "sprint")
			else :
				if prepare_smash or smash :
					$AnimatedSprite.play(sprite_with_hat + "smash")
				else :
					if jump or wall_jump or velocity.y < 0:
						if jump_flip :
							$AnimatedSprite.play(sprite_with_hat + "jumpflip")
						else:
							$AnimatedSprite.play(sprite_with_hat + "jump")

					if velocity.y > MAX_VSPEED / 5:
						if $AnimatedSprite.animation != (sprite_with_hat + "jump") and $AnimatedSprite.animation != (sprite_with_hat + "fall_after_jump") :
							$AnimatedSprite.play(sprite_with_hat + "fall")
						else :
							$AnimatedSprite.play(sprite_with_hat + "fall_after_jump")
					if climbing and velocity.y > 0:
						$AnimatedSprite.play(sprite_with_hat + "wall_climb")
			

	#slide
	if slide :
		$AnimatedSprite.play(sprite_with_hat + "slide")
		
	
	#teleport
	if teleport :
		$AnimatedSprite.play(sprite_with_hat + "stand")
	

#
##Animation ends
func _on_AnimatedSprite_animation_finished():
	if turning :
		turning = false
		if not ground :
			jump = false

	if prepare_smash :
		prepare_smash = false
		smash = true
		velocity.y = MAX_VSPEED/2

	throwing = false
	if $AnimatedSprite.animation == "hat_finish":
		velocity.y = -MAX_VSPEED/2
		$SFXFinish.play()


#
#blinking effect when get hit
func _on_VisibleTimer_timeout():
	is_visible = not is_visible


##Particles and Effects##
#
#Dust particles
func dust_particles():
	$SprintParticles.emitting = sprint and ground and abs(velocity.x)>=2*MAX_HSPEED or (turning and ground) 
	$JumpParticles.emitting = wall_jump or jump or smash or dive
	$SprintParticles.position.x = -8*sign(velocity.x)
	$ClimbParticles.emitting = climbing
	if $AnimatedSprite.flip_h:
		$ClimbParticles.position.x = -7
	else :
		$ClimbParticles.position.x = 7
#
#Wave Effect
func wave_effect(force):
	var node = WaveEffect.instance()
	get_parent().add_child(node)
	node.position = self.global_position
	node.scale = Vector2(force,force)

##camera##
#
#start a camera's shake
func start_camera_shake(power,t,period):
	camera_power = power
	camera_time = t
	camera_period = period
	camera_direction = rand_range(0,2*PI)
	time = 0
#
#camera's shake mouvement
func camera_shake():
	var camera = $CameraPosition/Camera
	var rad = camera_power * (camera_time-time) * cos((2*PI/camera_period)*time) * int(camera_time-time>0)
	camera.offset.x = rad * cos(camera_direction)
	camera.offset.y = -rad * sin(camera_direction)
#
#camera mouvements
func camera_manager(velocity):
	camera_shake()
	if finish:
		$CameraPosition/Camera.smoothing_enabled = true
	
	if ground :
		if $AnimatedSprite.flip_h and $CameraPosition.position.x > -50:
			$CameraPosition.position.x -= abs(-50 - $CameraPosition.position.x)/35
		elif not $AnimatedSprite.flip_h and $CameraPosition.position.x < 50:
			$CameraPosition.position.x += abs(50 - $CameraPosition.position.x)/35
	
#
#Signal to shake the camera
func _on_Mario_shake_camera(power,t,period):
	start_camera_shake(power,t,period)


##Final Level##
func _on_FinishTimer_timeout():
	velocity.y = 160
	$SFXSlide.play()
	
func slide_coins():
	var coin = Coin.instance()
	get_parent().add_child(coin)
	coin.emit_signal("destroy")
	
#
func finish_cinematic():	
	$AnimatedSprite.flip_h = false
	
	if finish_dance :
		velocity.x = 0
		$AnimatedSprite.speed_scale = 1
		jump_flip = false
	else :
		velocity.x += ACC * int(velocity.x <MAX_HSPEED)
		if ground and velocity.x >0:
			$AnimatedSprite.play(sprite_with_hat + "run_with_smears")
			$AnimatedSprite.speed_scale = abs(velocity.x)/MAX_HSPEED
			
	if velocity.y <0:
		if finish_dance:
			$AnimatedSprite.play(sprite_with_hat + "jump")
		else:
			$AnimatedSprite.rotation += 0.4
			$AnimatedSprite.play(sprite_with_hat + "jumpflip")
			
		$AnimatedSprite.speed_scale = 1
	elif velocity.y>0:
		$AnimatedSprite.rotation = 0
		$AnimatedSprite.play(sprite_with_hat + "fall")
	else :
		if finish_dance and ground:
			$AnimatedSprite.play("hat_finish")
			

	if velocity.y <= MAX_VSPEED:
		velocity.y += GRAVITY
#
func _on_Mario_finish_level():
	velocity.y = -1.2*JUMP_FORCE
	get_parent().get_node("Transition").emit_signal("goto_next_level")
	$SFXJump.play()
	slide = false
	reset_variables()
	$AnimatedSprite.rotation = 0
	start_camera_shake(0,0.4,0.1)
	jump_flip = true
	finish = true
	


##Items##
#
#area
func _on_ItemCollision_area_entered(area):
	if "Coin" in area.name :
		area.emit_signal("destroy_coin")
	
	if "Star" in area.name :
		area.emit_signal("destroy_star")
	
	if "FinalFlag" in area.name and not slide:
		velocity = Vector2(0,0)
		start_camera_shake(8,0.4,0.1)
		$SFXThrowCappy.play()
		$AnimatedSprite.rotation = 0
		if $AnimatedSprite.flip_h :
			global_position.x = area.position.x  + 3
		else :
			global_position.x = area.position.x  - 3
		slide = true
		smash = false
		throwing = false
		reset_variables()
		$FinishTimer.start()
		$JumpParticles.emitting = false
		area.emit_signal("raise_flag",self)
#
#body
func _on_ItemCollision_body_entered(body):
	if "QuestionBlock" in body.name:
		if smash :
			body.emit_signal("get_item",true)
			wave_effect(abs(velocity.y)/MAX_VSPEED)
			start_camera_shake(10,0.5,0.1)
			velocity.y = -MAX_VSPEED/3
			body.emit_signal("destroy")
			smash = false
			$AnimatedSprite.play(sprite_with_hat + "jump")
			$SFXSmash.play()

		elif jump or wall_jump:
			body.emit_signal("get_item",false)
			velocity.y = 0
	elif "Brick" in body.name:
		if smash :
			wave_effect(abs(velocity.y)/MAX_VSPEED)
			start_camera_shake(10,0.5,0.1)
			velocity.y = -MAX_VSPEED/8
			body.emit_signal("destroy")

		elif jump or wall_jump:
			start_camera_shake(8,0.3,0.1)
			velocity.y = 0
			jump = false
			wall_jump = false
			body.emit_signal("destroy")
	elif "Item" in body.name:
		body.emit_signal("destroy",self)
		wave_effect(0.5)
		start_camera_shake(7,0.5,0.2)
		$SFXPowerUp.play()


##Hit box##
#
#recieve_damge
func get_damage(body,damage):
	Scores.health -= damage
	$SFXHurt.play()
	reset_variables()
	can_hit = false
	hit = true
	$HitTimer.start()
	if self.global_position.x > body.global_position.x :
		velocity = Vector2(30,0)
		$AnimatedSprite.flip_h = true
	else :
		velocity = Vector2(-30,0)
		$AnimatedSprite.flip_h = false
	start_camera_shake(4*damage,0.3*damage,0.1)
	charge_time = 0
#
#when an enemy or cappy collids with mario
func _on_HitBox_body_entered(body):
	#cappy
	if "Cappy" in body.name :
		if not throwing and not body.back:
			velocity.y = -1.5*JUMP_FORCE
			turning = false
			dive = false
			jump = true
			cappy_jump = true
			$SFXDive.play()
			body.emit_signal("jump")
			
	#enemy	
	for enemy in EnemyList.enemy_body:
		if  can_hit:
			if enemy in body.name :
				if "Koopa" == enemy:
					if body.velocity.x == 0:
						body.emit_signal("kill",self)
						start_camera_shake(4,0.2,0.2)
					else :
						get_damage(body,1)
				else:
					get_damage(body,1)
#
#when mario collides with area that hurt
func _on_HitBox_area_entered(area):
	if "SolidKiller" in area.name:
		get_damage(area,3)
	for enemy in EnemyList.enemy_area:
		if enemy in area.name and can_hit :
			get_damage(area,1)

#Hit timer
func _on_HitTimer_timeout():
	if Scores.health <= 0:
		$DeadUI.emit_signal("start")
	else :
		hit = false
		can_hit = false
		$CanHitTimer.start()
#
#Can hit timer
func _on_CanHitTimer_timeout():
	can_hit = true


##attack enemies when jumping on them###
func _on_AttackBox_body_entered(body):
	
	for enemy in EnemyList.enemy_jump:
		if enemy in body.name and not hit :
			if smash:
				smash = false
				start_camera_shake(16,0.4,0.1)
				wave_effect(abs(velocity.y)/MAX_VSPEED)
			else :
				start_camera_shake(4,0.2,0.2)
			velocity.y = -JUMP_FORCE/1.2
			jump = true
			body.emit_signal("kill",self)
	


##reset variables##
func reset_variables():
	jump = false
	jump_flip = false
	wall_jump = false
	sprint = false
	turning = false
	climbing = false
	hit = false
	can_hit = true
	dive = false
	teleport = false



#throw cappy
func _on_AnimatedSprite_frame_changed():
	if throwing and $AnimatedSprite.frame == 4:
		velocity = Vector2(0,0)
		sprite_with_hat = "nohat_"
		var node = Cappy.instance()
		get_parent().add_child(node)
		node.mario = self
		node.global_position = $ThrowPosition2D.global_position
		if $AnimatedSprite.flip_h :
			node.velocity.x = -500
		else :
			node.velocity.x = 500

	if $AnimatedSprite.animation == sprite_with_hat + "run_with_smears" or  $AnimatedSprite.animation == sprite_with_hat + "sprint":
		if ($AnimatedSprite.frame == 2 or $AnimatedSprite.frame == 5) :
			$SFXFootStep.play()
