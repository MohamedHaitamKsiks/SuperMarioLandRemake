extends KinematicBody2D

signal start_level(scene_path)

var velocity = Vector2(0,0)
var can_move = true
var scene_path

const SPEED = 400
const PERIOD = 0.7
const AMP = -16

var y0
var time = 0

func _ready():
	y0 = $Sprite.position.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	time += delta
	
	if velocity == Vector2(0,0) and can_move:
		if Input.is_action_just_pressed("left") and not $RayCastLeft.is_colliding():
			velocity.x = -SPEED
			$SFXStep.play()
		elif Input.is_action_just_pressed("right") and not $RayCastRight.is_colliding():
			velocity.x = SPEED
			$SFXStep.play()
		elif Input.is_action_just_pressed("up") and not $RayCastUp.is_colliding():
			velocity.y = -SPEED
			$SFXStep.play()
		elif Input.is_action_just_pressed("down") and not $RayCastDown.is_colliding():
			velocity.y = SPEED
			$SFXStep.play()
			
	if not can_move:
		$Sprite.position.y = AMP * abs(sin(2*PI*time / PERIOD)) + y0
		if int($Sprite.position.y )== y0 and not $SFXStep.playing :
			$SFXStep.play()
	velocity = move_and_slide(velocity)


func _on_SFXStep_finished():
	if velocity != Vector2(0,0):
		$SFXStep.play()


func _on_Mario_start_level(scene_path):
	$SFXStart.play()
	can_move = false
	self.scene_path = scene_path


func _on_SFXStart_finished():
	get_parent().emit_signal("goto_level",scene_path)
