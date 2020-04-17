extends Node2D


signal quitOption()
export var blur = float(0.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Start")
	$Option/Options.visible = false
	
	if not GameData.load_game():
		$CanvasLayer/VBoxContainer/Load.disabled = true
	
func _process(delta):
	$CanvasLayer/Blur.get_material().set_shader_param("lod",2.0*blur)

func _on_Start_pressed():
	$AnimationPlayer.play("getMenu")


func _on_New_pressed():
	GameData.create_save_file()
	$AnimationPlayer.play("newGame")


func _on_Option_pressed():
	$Option/Options.visible = true
	$Option/Options/FullScreen.grab_focus()


func _on_Quit_pressed():
	get_tree().exit()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Start":
		if $CanvasLayer/VBoxContainer/Load.disabled :
			$CanvasLayer/VBoxContainer/New.grab_focus()
		else:
			$CanvasLayer/VBoxContainer/Load.grab_focus()
		$Music.play()
	elif anim_name == "getMenu" or anim_name == "newGame":
		get_tree().change_scene("res://Scenes/Worldmap/Worldmap.tscn")


func _on_MainMenu_quitOption():
	$Option/Options.visible = false
	$CanvasLayer/VBoxContainer/Option.grab_focus()

