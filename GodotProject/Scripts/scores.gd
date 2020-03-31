extends Node

var coins = 0
var health = 3
var lives = 3
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
	checkpoint = -1
	get_tree().reload_current_scene()
