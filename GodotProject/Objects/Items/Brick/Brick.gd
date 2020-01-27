extends StaticBody2D

signal destroy

var BrickParticle = preload("res://Objects/Particles/BrickParticle/BrickParticle.tscn")

#when destroyed
func _on_Brick_destroy():
	emit_particles(2)
	queue_free()

#emit particles
func emit_particles(number):
	for i in range(number + 1):
		var particle = BrickParticle.instance()
		get_parent().add_child(particle)
		particle.position = global_position + Vector2(-12,-12)
		var rad = rand_range(0,200)
		var angle = rand_range(0,2*PI)
		var pos = rand_range(0,16)
		particle.apply_impulse( Vector2(pos,pos) , Vector2(rad*cos(angle),rad*sin(angle)) )