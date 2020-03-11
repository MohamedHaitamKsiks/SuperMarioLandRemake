extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Start")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Start_pressed():
	$AnimationPlayer.play("getMenu")


func _on_Option_pressed():
	pass # Replace with function body.


func _on_Quit_pressed():
	get_tree().exit()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Start":
		$CanvasLayer/VBoxContainer/Start.grab_focus()
	elif anim_name == "getMenu":
		get_tree().change_scene("res://Scenes/Levels/FirstLevel/FirstLevel.tscn")
