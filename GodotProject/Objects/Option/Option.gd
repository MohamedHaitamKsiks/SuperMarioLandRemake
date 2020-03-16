extends CanvasLayer


#configFile
var config

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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Blur.visible = $Options.visible
	OS.window_fullscreen = $Options/FullScreen.value == 1
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),pow($Options/SFX.value/10.0,0.2) * 78.0 - 72.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("MUSIC"),pow($Options/Music.value/10.0,0.2) * 78.0 - 72.0)


func _on_Back_pressed():
	get_parent().emit_signal("quitOption")
	saveConfigFile(config)
	


#Config methods
	
func createConfigFile(config):
	if not config.has_section_key("video","fullscreen") :
		config.set_value("video","fullscreen",0)
	if not config.has_section_key("audio","music") :
		config.set_value("audio","music",5)
	if not config.has_section_key("audio","sfx") :
		config.set_value("audio","sfx",5)
	config.save("user://options.cfg")


func saveConfigFile(config):
	config.set_value("video","fullscreen",$Options/FullScreen.value)
	config.set_value("audio","sfx",$Options/SFX.value)
	config.set_value("audio","music",$Options/Music.value)
	config.save("user://options.cfg")

func loadFromConfigFile(config):
	$Options/FullScreen.value = config.get_value("video","fullscreen")
	$Options/SFX.value = config.get_value("audio","sfx")
	$Options/Music.value = config.get_value("audio","music")
