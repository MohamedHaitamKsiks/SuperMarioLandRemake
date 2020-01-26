extends KinematicBody2D

#signals
signal shake_camera(power,time,period)

#const
const GRAVITY = 10
const ACC = 20
const MAX_HSPEED = 150
const MAX_VSPEED = 500
const JUMP_FORCE = 180
const JUMP_ACC = 5
const FLOOR = Vector2(0,-1)

#variables
#mouvements variables
var velocity = Vector2(0,0)
var ground = false
var jump = true
var wall_jump = false
var sprint = false
var turning = false
var climbing = false
var hit = false
var can_hit = true
var is_visible = true
#camera variables
var camera_period = 1
var camera_power = 0
var camera_time = 1
var camera_direction = 0
var time = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	$VisibleTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if is_on_floor() :
		if not ground :
			turning = false
			$DustParticles.emitting = true
		ground = true
	else :
		ground = false
	if not hit :
		velocity = mouvement_manager(velocity)
	sprites_manager(velocity)
	camera_manager(velocity)
	velocity = move_and_slide(velocity,FLOOR)
	time += delta

#mouvement	
func mouvement_manager(velocity):
	
	$AnimatedSprite.visible = (is_visible and not can_hit) or can_hit
	
	#mvt
	var direction = + int(Input.is_action_pressed("ui_right"))-int(Input.is_action_pressed("ui_left"))
	velocity.x += ACC * direction * int(not wall_jump)
	velocity.x -= ACC * sign(velocity.x) * int(direction == 0) * int(not wall_jump)
	if abs(velocity.x) > MAX_HSPEED * ( 1 + int(sprint))  :#and not sprint:
		velocity.x = MAX_HSPEED * ( 1 + int(sprint)) * sign(velocity.x)
	if abs(velocity.x) < ACC :#and not sprint:
		velocity.x = 0
		
	#sprint
	sprint = Input.is_action_pressed("gameplay_sprint") 
	$SprintParticles.emitting = sprint and ground and abs(velocity.x)>=MAX_HSPEED or turning
	$JumpParticles.emitting = wall_jump or jump
	$SprintParticles.position.x = -8*sign(velocity.x)
	
	#climbing
	if $AnimatedSprite.flip_h:
		$CanClimbRayCastTop.cast_to.x = -12
		$CanClimbRayCastBot.cast_to.x = -12
	else :
		$CanClimbRayCastTop.cast_to.x = 12
		$CanClimbRayCastBot.cast_to.x = 12
	var cast_wall = $CanClimbRayCastTop.is_colliding() and $CanClimbRayCastBot.is_colliding()
	if is_on_wall() and (not ground) and cast_wall:
		climbing = true
		jump = false
		turning = false
		velocity.y = 0
		wall_jump = false
	else :
		climbing = false
		
	#walljump
	if Input.is_action_just_pressed("gameplay_jump") and climbing :
		velocity.y = -JUMP_FORCE*1.25
		velocity.x = -250*direction
		$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
		wall_jump = true
		turning = false 
		
		
	#jump
	if ground :
		jump = false
		climbing = false
		wall_jump = false
		
	if Input.is_action_just_pressed("gameplay_jump") and ground :
		velocity.y = -JUMP_FORCE
		jump = true
		turning = false 
		
	if Input.is_action_pressed("gameplay_jump") and jump :
		velocity.y -= JUMP_ACC
		
	
	if velocity.y >0 :
		jump = false
		wall_jump = false
		$AttackBox/CollisionShape2D.disabled = false
	else :
		$AttackBox/CollisionShape2D.disabled = true
		
	
	# gravity
	$AttackBox.position.y = 2*int(velocity.y>0)
	if velocity.y <= MAX_VSPEED:
		velocity.y += GRAVITY
	
	
		
	return velocity

#Animation end
func _on_AnimatedSprite_animation_finished():
	if turning :
		turning = false
		if not ground :
			jump = false
			


#sprites
func sprites_manager(velocity):
	
	$AnimatedSprite.scale.y = 1 + (velocity.y / MAX_VSPEED)*0.2 
	$AnimatedSprite.scale.x = 1 - abs(velocity.y / MAX_VSPEED)*0.2 
	
	if not turning:
		if ground :	
			if is_on_wall() :
				$AnimatedSprite.play("wall_walk")
			else :
				if velocity.x == 0:
					$AnimatedSprite.play("stand")
				elif abs(velocity.x) <= MAX_HSPEED:
					$AnimatedSprite.play("run_with_smears")
				else :
					$AnimatedSprite.play("sprint")
			
			
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
	if ((velocity.x > 0 and $AnimatedSprite.flip_h) or (velocity.x < 0 and not $AnimatedSprite.flip_h)) and not(turning or climbing or wall_jump or hit):
		$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h 
		turning = true
		climbing = false
		if ground :
			$AnimatedSprite.play("turn")
		else :
			$AnimatedSprite.play("turn_air")
	
#camera

func start_camera_shake(power,t,period):
	camera_power = power
	camera_time = t
	camera_period = period
	camera_direction = rand_range(0,2*PI)
	time = 0

func camera_shake():
	var camera = $CameraPosition/Camera
	var rad = camera_power * (camera_time-time) * cos((2*PI/camera_period)*time) * int(camera_time-time>0)
	camera.offset.x = rad * cos(camera_direction)
	camera.offset.y = -rad * sin(camera_direction)

func camera_manager(velocity):
	camera_shake()


func _on_ItemCollision_area_entered(area):
	if "Coin" in area.name :
		area.emit_signal("destroy_coin")
	

func _on_HitBox_body_entered(body):
	if "Goomba" in body.name and can_hit:
		Scores.health -= 1
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
		start_camera_shake(4,0.3,0.2)
		

func _on_HitTimer_timeout():
	if Scores.health <= 0:
		$DeadUI.emit_signal("start")
	else :
		hit = false
		can_hit = false
	$	CanHitTimer.start()
	
func _on_CanHitTimer_timeout():
	can_hit = true


func _on_AttackBox_body_entered(body):
	if "Goomba" in body.name and not hit :
		velocity.y = -JUMP_FORCE/2
		body.emit_signal("kill",self)
		start_camera_shake(4,0.2,0.2)
		

func _on_Mario_shake_camera(power,t,period):
	start_camera_shake(power,t,period)

func reset_variables():
	jump = false
	wall_jump = false
	sprint = false
	turning = false
	climbing = false
	hit = false
	can_hit = true


func _on_VisibleTimer_timeout():
	is_visible = not is_visible
	#$VisibleTimer.start()
