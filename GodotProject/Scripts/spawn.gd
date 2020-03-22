extends Node2D


# Declare member variables here. Examples:
# var a = 2
export var next_level = ""
export var title = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	if Scores.checkpoint != -1 :
		var checkpointNode = get_node("Checkpoint" + str(Scores.checkpoint))
		$Mario.position = checkpointNode.position + checkpointNode.get_node("SpawnPosition").position
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
