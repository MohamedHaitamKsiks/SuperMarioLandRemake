extends Button


export var value = 0
export var max_value = 0
var focus = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if max_value == 1:
		if value == 1:
			$HBoxContainer/Label.text = "on"
		else :
			$HBoxContainer/Label.text = "off"
	elif max_value == 0:
		$HBoxContainer.visible = false
	else :
		$HBoxContainer/Label.text = str(value) 
	
	if focus :
		if Input.is_action_just_pressed("ui_right") and value < max_value:
			value+=1
			$SFXModify.play()
		elif Input.is_action_just_pressed("ui_left") and value > 0:
			value-=1
			$SFXModify.play()
	
	if value < max_value and value > 0:
		$HBoxContainer/ArrowLeft.visible = true
		$HBoxContainer/ArrowRight.visible = true
	elif value == max_value :
		$HBoxContainer/ArrowLeft.visible = false
		$HBoxContainer/ArrowRight.visible = true
	elif value == 0:
		$HBoxContainer/ArrowLeft.visible = true
		$HBoxContainer/ArrowRight.visible = false

func _on_OptionButton_focus_entered():
	$AnimationPlayer.play("focusOn")
	$SFXFocus.play()
	focus = not focus


func _on_OptionButton_focus_exited():
	$AnimationPlayer.play("focusOff")
	focus = not focus


