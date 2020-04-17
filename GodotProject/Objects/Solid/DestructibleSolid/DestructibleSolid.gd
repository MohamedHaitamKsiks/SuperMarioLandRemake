extends StaticBody2D

var SmallExplosion = preload("res://Objects/Particles/SmallExplosion/SmallExplosion.tscn")

signal destroy(mario)

var Mario

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_DestructibleSolid_destroy(mario):
	Mario = mario
	$Timer.start()


func _on_Timer_timeout():
	var explosion = SmallExplosion.instance()
	get_parent().add_child(explosion)
	explosion.mario = Mario
	explosion.global_position = global_position
	Mario.emit_signal("shake_camera",8,0.4,0.1)
	queue_free()
