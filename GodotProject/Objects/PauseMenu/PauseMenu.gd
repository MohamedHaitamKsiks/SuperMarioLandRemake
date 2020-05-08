extends CanvasLayer

export var blur = float(0.0)
export var quit_scene = "res://Scenes/Worldmap/Worldmap.tscn"
var paused = false

var select = 0
var can_move = false
var button_group

signal quitOption()

# Called when the node enters the scene tree for the first time.
func _ready():
	$Option/ScrollContainer/Options.visible = false
	button_group = $ButtonPosition/Buttons.get_children()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	draw_blur()
	if Input.is_action_just_pressed("ui_pause") and not paused:
			get_tree().paused = true
			$PauseSFX.play()
			$AnimationPlayer.play("pauseIn")
			paused = true
	
	if can_move and paused: 
		pause()

func draw_blur():
	$Blur.get_material().set_shader_param("lod",2.0*blur)


func _on_Quit_pressed():
	$AnimationPlayer.play("quit")
	if "Worldmap" in get_parent().name:
		for node in get_parent().get_node("GroupOfMusics").get_children():
			node.stop()
		return
	get_parent().get_node("Music").stop()
	can_move = false

func _on_Resume_pressed():
	if paused :
		$AnimationPlayer.play("pauseOut")
		$ButtonPosition/Buttons/Resume.release_focus()
		can_move = false

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "pauseIn":
		$ButtonPosition/Buttons/Resume.grab_focus()
		can_move = true
	elif anim_name == "pauseOut" and paused:
		get_tree().paused = false
		paused = false
	elif anim_name == "quit":
		get_tree().paused = false
		get_tree().change_scene(quit_scene)


func _on_Button_pressed():
	$Option/ScrollContainer/Options.visible = true
	$Option/ScrollContainer/Options/FullScreen.grab_focus()
	can_move = false

func _on_PauseMenu_quitOption():
	
	$Option/ScrollContainer/Options.visible = false
	can_move = true
	$ButtonPosition/Buttons/Options.grab_focus()

func pause():

	if Input.is_action_just_pressed("down"):
		select += 1
	if Input.is_action_just_pressed("up"):
		select -= 1
		
	if select < 0:
		select = 2
	if select > 2:
		select = 0
		
	if not button_group[select].has_focus():
		button_group[select].grab_focus()
