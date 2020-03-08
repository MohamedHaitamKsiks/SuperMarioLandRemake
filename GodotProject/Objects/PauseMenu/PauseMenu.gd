extends CanvasLayer

export var blur = float(0.0)
var paused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	draw_blur()
	if Input.is_action_just_pressed("ui_accept") and not paused:
			get_tree().paused = true
			$AnimationPlayer.play("pauseIn")
			paused = true

func draw_blur():
	$Blur.get_material().set_shader_param("lod",2.0*blur)


func _on_Quit_pressed():
	get_tree().quit()


func _on_Resume_pressed():
	if paused :
		get_tree().paused = false
		$AnimationPlayer.play("pauseOut")
		paused = false
		$ButtonPosition/Buttons/Resume.release_focus()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "pauseIn":
		$ButtonPosition/Buttons/Resume.grab_focus()


func _on_Button_pressed():
	pass
