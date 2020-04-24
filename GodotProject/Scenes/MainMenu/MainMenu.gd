extends Node2D


signal quitOption()
export var blur = float(0.0)


var select = 0

var can_move = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Start")
	$Option/ScrollContainer/Options.visible = false
	
	if not GameData.load_game():
		$CanvasLayer/VBoxContainer/Load.disabled = true
	
func _process(delta):
	$CanvasLayer/Blur.get_material().set_shader_param("lod",2.0*blur)
	if can_move and not $Option/ScrollContainer.visible:
		mainmenu()


func _on_Start_pressed():
	$AnimationPlayer.play("getMenu")
	can_move = false


func _on_New_pressed():
	GameData.create_save_file()
	$AnimationPlayer.play("newGame")
	can_move = false


func _on_Option_pressed():
	$Option/ScrollContainer/Options.visible = true
	$Option/ScrollContainer/Options/FullScreen.grab_focus()


func _on_Quit_pressed():
	get_tree().exit()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Start":
		if $CanvasLayer/VBoxContainer/Load.disabled :
			$CanvasLayer/VBoxContainer/New.grab_focus()
		else:
			$CanvasLayer/VBoxContainer/Load.grab_focus()
		can_move = true
		$Music.play()
	elif anim_name == "getMenu" or anim_name == "newGame":
		get_tree().change_scene("res://Scenes/Worldmap/Worldmap.tscn")


func _on_MainMenu_quitOption():
	$Option/ScrollContainer/Options.visible = false
	$CanvasLayer/VBoxContainer/Option.grab_focus()



func mainmenu():
	var button_group = $CanvasLayer/VBoxContainer
	
	if Input.is_action_just_pressed("down"):
		select += 1
	if Input.is_action_just_pressed("up"):
		select -= 1
		
	if select < 0:
		select = 3
	if select > 3:
		select = 0
	if not button_group.get_children()[select].has_focus():
		button_group.get_children()[select].grab_focus()
