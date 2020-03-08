extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_hovered():
		grab_focus()
	


func _on_Button_focus_entered():
	$AnimationPlayer.play("focusEntered")
	


func _on_Button_focus_exited():
	$AnimationPlayer.play("focusExit")



