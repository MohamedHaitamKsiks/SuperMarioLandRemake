extends KinematicBody2D

#const
const GRAVITY = 10
const ACC = 20
const MAX_HSPEED = 150
const MAX_VSPEED = 500
const JUMP_FORCE = 180
const JUMP_ACC = 5
const FLOOR = Vector2(0,-1)

#variables
var velocity = Vector2(0,0)
var ground = false
var jump = true
var wall_jump = false
var sprint = false
var turning = false
var climbing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if is_on_floor() :
		if not ground :
			turning = false
		ground = true
	else :
		ground = false
	velocity = mouvement_manager(velocity)
	sprites_manager(velocity)
	camera_manager(velocity)
	velocity = move_and_slide(velocity,FLOOR)

#mouvement	
func mouvement_manager(velocity):
	#mvt
	var direction = + int(Input.is_action_pressed("ui_right"))-int(Input.is_action_pressed("ui_left"))
	var max_speed = int( abs(velocity.x) < MAX_HSPEED * ( 1 + int(sprint)* int(direction != 0) ) ) 
	velocity.x += ACC * direction * max_speed * int(not wall_jump)
	velocity.x -= ACC * sign(velocity.x) * int(direction == 0) * int(not wall_jump)
	if abs(velocity.x) >= MAX_HSPEED  :#and not sprint:
		velocity.x -= ACC * sign(velocity.x)
	if abs(velocity.x) < ACC :#and not sprint:
		velocity.x = 0
		
	#sprint
	sprint = Input.is_action_pressed("gameplay_sprint") 
	
	#climbing
	if is_on_wall() and (not ground):
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
		
	
	# gravity
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
	$AnimatedSprite.scale.x = 1 - (velocity.y / MAX_VSPEED)*0.2
	
	if not turning:
		if ground :	
			if is_on_wall() :
				$AnimatedSprite.play("wall_walk")
			else :
				if velocity.x == 0:
					$AnimatedSprite.play("stand")
				elif abs(velocity.x) < MAX_HSPEED:
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
				
	if ((velocity.x > 0 and $AnimatedSprite.flip_h) or (velocity.x < 0 and not $AnimatedSprite.flip_h)) and not(turning or climbing or wall_jump):
		$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h 
		turning = true
		climbing = false
		if ground :
			$AnimatedSprite.play("turn")
		else :
			$AnimatedSprite.play("turn_air")

#camera
func camera_manager(velocity):
	#$CameraPosition.position.x = velocity.x/20
	#var zoom = 0.35 + abs(velocity.x) / (100 * MAX_HSPEED)
	#$CameraPosition/Camera.zoom = Vector2(zoom , zoom)
	pass


func _on_ItemCollision_area_entered(area):
	if "Coin" in area.name :
		area.emit_signal("destroy_coin")
