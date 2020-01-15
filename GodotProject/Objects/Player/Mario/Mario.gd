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
var sprint = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	ground = is_on_floor()
	velocity = mouvement_manager(velocity)
	sprites_manager(velocity)
	camera_manager(velocity)
	velocity = move_and_slide(velocity,FLOOR)

#mouvement	
func mouvement_manager(velocity):
	#mvt
	var max_speed = int( abs(velocity.x) < MAX_HSPEED * ( 1 + int(sprint) ) )
	var direction = + int(Input.is_action_pressed("ui_right"))-int(Input.is_action_pressed("ui_left"))
	velocity.x += ACC * direction * max_speed
	velocity.x -= ACC * sign(velocity.x) * int(direction == 0)
	if abs(velocity.x) >= MAX_HSPEED  and not sprint:
		velocity.x -= ACC * sign(velocity.x)
		
	#sprint
	sprint = Input.is_action_pressed("gameplay_sprint") 
		
	#jump
	if ground :
		jump = false
		
	if Input.is_action_just_pressed("gameplay_jump") and ground :
		velocity.y = -JUMP_FORCE
		jump = true
		
	if Input.is_action_pressed("gameplay_jump") and jump :
		velocity.y -= JUMP_ACC
	
	if velocity.y >0 :
		jump = false
	
	# gravity
	if velocity.y <= MAX_VSPEED:
		velocity.y += GRAVITY
		
	return velocity

#sprites
func sprites_manager(velocity):
	if velocity.x > 0 :
		$AnimatedSprite.flip_h = false
	if velocity.x < 0 :
		$AnimatedSprite.flip_h = true
	
	if ground:	
		if velocity.x == 0:
			$AnimatedSprite.play("stand")
		elif abs(velocity.x) < MAX_HSPEED:
			$AnimatedSprite.play("run_with_smears")
		else :
			$AnimatedSprite.play("sprint")
		
	else :
		if jump :
			$AnimatedSprite.play("jump")
		if velocity.y > MAX_VSPEED / 4 :
			if $AnimatedSprite.animation != "jump" and $AnimatedSprite.animation != "fall_after_jump":
				$AnimatedSprite.play("fall")
			else :
				$AnimatedSprite.play("fall_after_jump")

#camera
func camera_manager(velocity):
	#$CameraPosition.position.x = velocity.x/20
	#var zoom = 0.35 + abs(velocity.x) / (100 * MAX_HSPEED)
	#$CameraPosition/Camera.zoom = Vector2(zoom , zoom)
	pass