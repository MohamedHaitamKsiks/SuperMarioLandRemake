extends Node2D


signal quitOption()


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Start")
	$Option/Options.visible = false




func _on_Start_pressed():
	$AnimationPlayer.play("getMenu")


func _on_Option_pressed():
	$Option/Options.visible = true
	$Option/Options/FullScreen.grab_focus()


func _on_Quit_pressed():
	get_tree().exit()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Start":
		$CanvasLayer/VBoxContainer/Start.grab_focus()
	elif anim_name == "getMenu":
		get_tree().change_scene("res://Scenes/Levels/FirstLevel/FirstLevel.tscn")


func _on_MainMenu_quitOption():
	$Option/Options.visible = false
	$CanvasLayer/VBoxContainer/Option.grab_focus()
