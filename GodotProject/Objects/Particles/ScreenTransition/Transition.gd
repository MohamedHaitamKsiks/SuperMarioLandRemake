extends CanvasLayer

export var next_level = ""
signal goto_next_level()


func _on_AnimationPlayer_animation_finished(anim_name):
	Scores.goto_level(next_level)


func _on_Transition_goto_next_level():
	$AnimationPlayer.play("fadeIn")
