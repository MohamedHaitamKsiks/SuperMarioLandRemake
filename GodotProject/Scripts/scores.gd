extends Node

var coins = 0
var health = 3
var lives = 3
var stars = 0
var level_stars = [false,false,false]
var blur = 0
var checkpoint = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func goto_level(scene):
	health = 3
	checkpoint = -1
	get_tree().change_scene(scene)

func restart_level():
	health = 3
	lives = 3
	coins = int(coins / 2)
	checkpoint = -1
	get_tree().reload_current_scene()
	for k in range(3):
		level_stars[k] = false
