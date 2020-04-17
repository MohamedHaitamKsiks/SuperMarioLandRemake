extends Node


var coins = 0
var health = 3
var lives = 3
var stars = 0

var level_id = -1
var level_stars = []
var level_path = []

var checkpoint = -1

var blur = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	level_path.append("res://Scenes/Levels/World1/Level1.tscn")
	level_path.append("res://Scenes/Levels/World1/Level2.tscn")
	level_path.append("res://Scenes/Levels/World1/Level3.tscn")
	
	for k in range(3):
		level_stars.append([false,false,false])
		
		
func goto_level(scene):
	health = 3
	checkpoint = -1
	get_tree().change_scene(scene)

func restart_level():
	health = 3
	get_tree().paused = false
	get_tree().reload_current_scene()


func game_over():
	health = 3
	lives = 3
	coins = int(coins / 2)
	checkpoint = -1
	get_tree().change_scene("res://Scenes/Worldmap/Worldmap.tscn")
