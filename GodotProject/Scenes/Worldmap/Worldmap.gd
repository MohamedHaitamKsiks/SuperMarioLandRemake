extends Node

signal goto_level(scene_path)

var scene_path

# Called when the node enters the scene tree for the first time.
func _ready():
	$HUD/ColorRect.visible = true
	$Tilemap/TileMapSolid.visible = false
	$AnimationPlayer.play("fadeOut")
	for e in $GroupOfDestination.get_children() :
		if e.level_id == Scores.level_id :
			$Mario.global_position = e.global_position
			break
	
	if not GameData.load_game() :
		GameData.create_save_file()

func _process(delta):
	$HUD/Counters/coins.text = "X" + str(Scores.coins)
	$HUD/Counters/stars.text = "X" + str(Scores.stars)
	$HUD/Counters/lives.text = "X" + str(Scores.lives)
	
	$HUD/CountersShadows/coins.text = "X" + str(Scores.coins)
	$HUD/CountersShadows/stars.text = "X" + str(Scores.stars)
	$HUD/CountersShadows/lives.text = "X" + str(Scores.lives)


func _on_Worldmap_goto_level(scene_path):
	self.scene_path = scene_path
	$AnimationPlayer.play("fadeIn")
	


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fadeIn":
		Scores.goto_level(scene_path)
	elif anim_name == "fadeOut":
		$GroupOfMusics/Music1.play()
