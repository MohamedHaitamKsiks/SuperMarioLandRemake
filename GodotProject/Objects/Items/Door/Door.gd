extends Area2D

export var underworld_music = false
export var overworld_music = false

var Mario
var collide_with_mario
var teleport = false
var door_out

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if collide_with_mario and Input.is_action_just_pressed("up") and not teleport and (Mario.can_move and Mario.ground and not (Mario.dive or Mario.jump or Mario.throwing)):
		if self.has_node("DoorOut"):
			door_out = $DoorOut
			get_parent().get_parent().get_node("Transition").get_node("AnimationPlayer").play("teleport")
		else:
			door_out = get_parent()
			get_parent().get_parent().get_parent().get_node("Transition").get_node("AnimationPlayer").play("teleport")
		
		door_out.get_node("AnimatedSprite").z_index = 10
		
		teleport = true
		
		Mario.velocity = Vector2(0,0)
		Mario.can_move = false
		Mario.reset_variables()
		
		$AnimatedSprite.play("open")
		$SFXOpen.play()
		

func _on_Door_body_entered(body):
	if "Mario" in body.name:
		collide_with_mario = true
		Mario = body


func _on_Door_body_exited(body):
	if "Mario" in body.name:
		collide_with_mario = false


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "open":
		$SFXClose.play()
		$AnimatedSprite.play("close")
		if teleport:
			$AnimatedSprite.z_index = 10
		else:
			$AnimatedSprite.z_index = -1
	
	elif $AnimatedSprite.animation == "close":
		if teleport:
			door_out.get_node("AnimatedSprite").play("open")
			Mario.position = door_out.global_position + Vector2(0,7)
			teleport = false
			$AnimatedSprite.z_index = -1
			return
		Mario.can_move = true
	
	
