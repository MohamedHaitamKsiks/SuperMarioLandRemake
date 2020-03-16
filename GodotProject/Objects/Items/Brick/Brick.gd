extends StaticBody2D

signal destroy

var BrickParticle = preload("res://Objects/Particles/BrickParticle/BrickParticle.tscn")

#when destroyed
func _on_Brick_destroy():
	emit_particles(2)
	queue_free()

#emit particles
func emit_particles(number):
	var particle = BrickParticle.instance()
	get_parent().add_child(particle)
	particle.position = global_position + Vector2(-24,-24)
	particle.emitting = true
	
