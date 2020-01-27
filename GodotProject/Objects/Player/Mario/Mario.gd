extends KinematicBody2D

#import object to instance
const WaveEffect = preload("res://Objects/Particles/WaveEffect/WaveEffect.tscn")

#signals
signal shake_camera(power,time,period)
signal transform(mode)


#const
const GRAVITY = 10
const ACC = 20
const MAX_HSPEED = 160
const MAX_VSPEED = 500
const JUMP_FORCE = 180
const JUMP_ACC = 5
const FLOOR = Vector2(0,-1)


#variables
#modes
var fire_mode = false
var star_mode = false
#mouvements
var velocity = Vector2(0,0)
var ground = false
#jumping
var jump = true
var wall_jump = false
var climbing = false
#down/smash
var down = false
var prepare_smash = false
var smash = false
#run
var sprint = false
var turning = false
#hit
var hit = false
var can_hit = true
var is_visible = true
#camera
var camera_period = 1
var camera_power = 0
var camera_time = 1
var camera_direction = 0
var time = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	on_floor()
	if not (hit or prepare_smash):
		velocity = mouvement_manager(velocity)
	sprites_manager(velocity)
	camera_manager(velocity)
	dust_particles()
	velocity = move_and_slide(velocity,FLOOR)
	time += delta


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
			$DustParticles.emitting = true
		jump = false
		climbing = false
		wall_jump = false
		ground = true
	else :
		ground = false
	
		
##mouvements##	
func mouvement_manager(velocity):
	#blinking effects
	$AnimatedSprite.visible = (is_visible and not can_hit) or can_hit
	
	#basic mouvements
	var direction = int(Input.is_action_pressed("ui_right"))-int(Input.is_action_pressed("ui_left"))
	velocity.x += ACC * direction * int(not wall_jump and not down and not smash)#acceleration
	velocity.x -= ACC * sign(velocity.x) * int(direction == 0 or down or smash) * int(not wall_jump)#deceleration
	if abs(velocity.x) > MAX_HSPEED * ( 1 + int(sprint))  :#max speed
		velocity.x = MAX_HSPEED * ( 1 + int(sprint)) * sign(velocity.x)
	if abs(velocity.x) < ACC :
		velocity.x = 0
		
	#sprining
	sprint = Input.is_action_pressed("gameplay_sprint") 
	
	#down
	down = Input.is_action_pressed("ui_down") and ground and not smash

	#smash
	if not (ground or smash or prepare_smash) and Input.is_action_just_pressed("ui_down"):
		prepare_smash = true
		velocity = Vector2(0,0)
	$ItemCollision.position.y = 16* velocity.y / MAX_VSPEED
	
	#climbing
	##ray cast to wall
	if $AnimatedSprite.flip_h:
		$CanClimbRayCastTop.cast_to.x = -12
		$CanClimbRayCastBot.cast_to.x = -12
	else :
		$CanClimbRayCastTop.cast_to.x = 12
		$CanClimbRayCastBot.cast_to.x = 12
	var cast_wall = $CanClimbRayCastTop.is_colliding() and $CanClimbRayCastBot.is_colliding()
	#if on wall => climb 
	if is_on_wall() and (not ground) and cast_wall:
		climbing = true
		jump = false
		turning = false
		velocity.y = 10
		wall_jump = false
	else :
		climbing = false
		
	#walljump
	if Input.is_action_just_pressed("gameplay_jump") and climbing :
		velocity.y = -JUMP_FORCE*1.5
		velocity.x = -250*direction
		$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
		wall_jump = true
		turning = false 
		
	#jump		
	if Input.is_action_just_pressed("gameplay_jump") and ground :
		velocity.y = -JUMP_FORCE
		jump = true
		turning = false 
	##long jump
	if Input.is_action_pressed("gameplay_jump") and jump :
		velocity.y -= JUMP_ACC
	#stop jumping
	if velocity.y >0 :
		jump = false
		wall_jump = false
		$AttackBox/CollisionShape2D.disabled = false
	else :
		$AttackBox/CollisionShape2D.disabled = true
		
	# gravity
	$AttackBox.position.y = 4*int(velocity.y>0)
	if velocity.y <= MAX_VSPEED:
		velocity.y += GRAVITY
		
	return velocity

	
##Animed Sprite##
#
#sprite
func sprites_manager(velocity):
	#falling stretch
	$AnimatedSprite.scale.y = 1 + (velocity.y / MAX_VSPEED)*0.2 
	$AnimatedSprite.scale.x = 1 - abs(velocity.y / MAX_VSPEED)*0.2 
	
	#sprite
	if not turning:
		#on ground
		if ground :	
			if is_on_wall() :
				$AnimatedSprite.play("wall_walk")
			else :
				if down :
					$AnimatedSprite.play("down")
				else :
					if velocity.x == 0:
						$AnimatedSprite.play("stand")
					elif abs(velocity.x) <= MAX_HSPEED:
						$AnimatedSprite.play("run_with_smears")
					else :
						$AnimatedSprite.play("sprint")
		else :
			if prepare_smash or smash :
				$AnimatedSprite.play("smash")
			else :
				if jump or wall_jump:
					$AnimatedSprite.play("jump")			
				if velocity.y > MAX_VSPEED / 4 :
					if $AnimatedSprite.animation != "jump" and $AnimatedSprite.animation != "fall_after_jump":
						$AnimatedSprite.play("fall")
					else :
						$AnimatedSprite.play("fall_after_jump")
				if climbing :
					$AnimatedSprite.play("wall_climb")
		if hit :
			$AnimatedSprite.play("hit")
	#turning
	if ((velocity.x > 0 and $AnimatedSprite.flip_h) or (velocity.x < 0 and not $AnimatedSprite.flip_h)) and not(turning or climbing or wall_jump or hit):
		$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h 
		turning = true
		climbing = false
		if ground :
			$AnimatedSprite.play("turn")
		else :
			$AnimatedSprite.play("turn_air")
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
#
#blinking effect when get hit
func _on_VisibleTimer_timeout():
	is_visible = not is_visible


##Particles and Effects##
#
#Dust particles
func dust_particles():
	$SprintParticles.emitting = sprint and ground and abs(velocity.x)>=MAX_HSPEED or turning
	$JumpParticles.emitting = wall_jump or jump or smash
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
#
#Signal to shake the camera
func _on_Mario_shake_camera(power,t,period):
	start_camera_shake(power,t,period)


##Items##
#
#area
func _on_ItemCollision_area_entered(area):
	if "Coin" in area.name :
		area.emit_signal("destroy_coin")	
#
#body
func _on_ItemCollision_body_entered(body):
	if "QuestionBlock" in body.name:
		if smash :
			body.emit_signal("get_item",true)
			wave_effect(abs(velocity.y)/MAX_VSPEED)
			start_camera_shake(10,0.5,0.1)
			if Input.is_action_pressed("ui_down"):
				velocity.y = -MAX_VSPEED/3
		elif jump :
			body.emit_signal("get_item",false)
	elif "Brick" in body.name:
		if smash :
			wave_effect(abs(velocity.y)/MAX_VSPEED)
			start_camera_shake(10,0.5,0.1)
			velocity.y = -MAX_VSPEED/4
			body.emit_signal("destroy")
		elif jump :
			start_camera_shake(8,0.3,0.1)
			body.emit_signal("destroy")
	elif "Item" in body.name:
		body.emit_signal("destroy",fire_mode,self)
		wave_effect(0.5)
		start_camera_shake(7,0.5,0.2)

##Hit box##
#
#recieve_damge
func get_damage(body,damage):
	Scores.health -= damage
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
#
#when an enemy collids with mario
func _on_HitBox_body_entered(body):
	if "Goomba" in body.name and can_hit:
		get_damage(body,1)
#
#when mario collides with area that hurt
func _on_HitBox_area_entered(area):
	if "SolidKiller" in area.name:
		get_damage(area,3)

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
	if "Goomba" in body.name and not hit :
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
	wall_jump = false
	sprint = false
	turning = false
	climbing = false
	hit = false
	can_hit = true



