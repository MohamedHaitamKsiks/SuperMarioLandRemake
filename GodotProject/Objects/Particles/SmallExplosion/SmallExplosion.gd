extends Area2D

var mario

func _on_AnimatedSprite_animation_finished():
	queue_free()


func _on_SmallExplosion_body_entered(body):
	if "DestructibleSolid" in body.name :
		body.emit_signal("destroy",mario)
