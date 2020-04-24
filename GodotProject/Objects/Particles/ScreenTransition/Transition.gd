extends CanvasLayer

export var next_level = ""

signal goto_next_level()

var finish = false


func _on_AnimationPlayer_animation_finished(anim_name):
	if finish :
		Scores.goto_level(next_level)
		GameData.save_game()


func _on_Transition_goto_next_level():
	$AnimationPlayer.play("fadeIn")
	finish = true
