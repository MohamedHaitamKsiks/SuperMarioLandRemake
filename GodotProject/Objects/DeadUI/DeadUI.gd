extends CanvasLayer

export var blur = float(0.0)
signal start

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	draw_blur()
	$LiveCounter/LiveAfter.text = "X "+ str((Scores.lives - Scores.lives%10)/10) + str(Scores.lives%10)
	$LiveCounter/LiveBefore.text = "X "+ str((Scores.lives+1 - (Scores.lives+1)%10)) +str((Scores.lives+1)%10)

func draw_blur():
	$BlurRect.get_material().set_shader_param("lod",blur)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "start":
		if Scores.lives == 0:
			$AnimationPlayer.play("game_over")
			return
		get_tree().paused = false
		get_tree().reload_current_scene()
	else :
		get_tree().paused = false
		Scores.restart_level()

func _on_DeadUI_start():
	$AnimationPlayer.play("start")
	get_parent().get_parent().get_node("Music").stop()
	$SFXDie.play()
	Scores.health = 3
	Scores.lives -= 1
	get_tree().paused = true
