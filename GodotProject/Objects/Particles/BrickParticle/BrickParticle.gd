extends Node2D

var debrit = preload("res://Objects/Particles/BrickParticle/BrickDebrit.tscn")
var blink = 0

func _ready():
	for k in range(5):
		var node = debrit.instance()
		add_child(node)
		node.velocity.x = 70 * cos(2 * k * PI / 5 + rand_range(0,PI/7))
		node.velocity.y = 120* sin(2 * k * PI / 5 + rand_range(0,PI/7)) - 150
			
func _on_Timer_timeout():
	queue_free()


func _on_Blink_timeout():
	if blink < 3:
		$impact.visible = not $impact.visible
		$impact.modulate = Color(1.0 - int(blink >= 3),1.0 - int(blink >= 2),1.0 - int(blink >= 1),1.0)
		blink += 1
		return
	$impact.visible = false
	
