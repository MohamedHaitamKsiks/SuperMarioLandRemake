extends CanvasLayer


#configFile
var config

var select = 0
var button_group = []

var actions_list = ["gameplay_jump","gameplay_sprint","gameplay_throwcappy","gameplay_dive","gameplay_down"]

var controls = false

# Called when the node enters the scene tree for the first time.
func _ready():
	config = ConfigFile.new()
	var err = config.load("user://options.cfg")
	if err == OK :
		createConfigFile(config)
		loadFromConfigFile(config)
	else :
		config.save("user://options.cfg")
		createConfigFile(config)
		
	for n in $ScrollContainer/Options.get_children():
		if n.get_class() == "Button":
			button_group.append(n)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Blur.visible = $ScrollContainer/Options.visible
	$ScrollContainer.visible = $ScrollContainer/Options.visible
	OS.window_fullscreen = $ScrollContainer/Options/FullScreen.value == 1
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),pow($ScrollContainer/Options/SFX.value/10.0,0.2) * 78.0 - 72.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("MUSIC"),pow($ScrollContainer/Options/Music.value/10.0,0.2) * 78.0 - 72.0)
	
	if $ScrollContainer/Options/FullScreen.focus:
		$ScrollContainer.scroll_vertical = 0
	if $ScrollContainer.visible and not controls :
		option()

func _on_Back_pressed():
	get_parent().emit_signal("quitOption")
	saveConfigFile(config)
	$ScrollContainer/Options/Back/SFXModify.play()
	


#Config methods
	
func createConfigFile(config):
	if not config.has_section_key("video","fullscreen") :
		config.set_value("video","fullscreen",0)
	if not config.has_section_key("audio","music") :
		config.set_value("audio","music",5)
	if not config.has_section_key("audio","sfx") :
		config.set_value("audio","sfx",5)
	createControls(config)
	config.save("user://options.cfg")

func createControls(config):
	for action in actions_list:
		if not config.has_section_key("keyboard",action):
			config.set_value("keyboard",action,InputMap.get_action_list(action)[0])
		if not config.has_section_key("gamepad",action):
			config.set_value("gamepad",action,InputMap.get_action_list(action)[1])
		

func saveControls(config):
	for action in actions_list:
		config.set_value("keyboard",action,InputMap.get_action_list(action)[0])
		config.set_value("gamepad",action,InputMap.get_action_list(action)[1])
		
func saveConfigFile(config):
	config.set_value("video","fullscreen",$ScrollContainer/Options/FullScreen.value)
	config.set_value("audio","sfx",$ScrollContainer/Options/SFX.value)
	config.set_value("audio","music",$ScrollContainer/Options/Music.value)
	saveControls(config)
	config.save("user://options.cfg")

func loadFromConfigFile(config):
	$ScrollContainer/Options/FullScreen.value = config.get_value("video","fullscreen")
	$ScrollContainer/Options/SFX.value = config.get_value("audio","sfx")
	$ScrollContainer/Options/Music.value = config.get_value("audio","music")
	for action in actions_list:
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, config.get_value("keyboard",action))
		InputMap.action_add_event(action, config.get_value("gamepad",action))
	
	
func option():

	if Input.is_action_just_pressed("down"):
		select += 1
	if Input.is_action_just_pressed("up"):
		select -= 1
		
	if select < 0:
		select = 5
	if select > 5:
		select = 0
	if not button_group[select].has_focus():
		button_group[select].grab_focus()


func _on_Keyboard_pressed():
	$Keyboard/ScrollContainer.visible = true
	$Keyboard.last_focus = $ScrollContainer/Options/Keyboard
	$Keyboard/ScrollContainer/Controls/Jump.grab_focus()
	controls = true


func _on_Gamepad_pressed():
	$Gamepad/ScrollContainer.visible = true
	$Gamepad.last_focus = $ScrollContainer/Options/Gamepad
	$Gamepad/ScrollContainer/Controls/Jump.grab_focus()
	controls = true
