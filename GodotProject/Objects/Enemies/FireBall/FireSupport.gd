extends Sprite


export var period = 0
export var phi = 0

var theta = 0
var time = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	time += delta
	
	theta = 2 * PI * time / period + phi
	
	var radius = 0
	
	for n in get_children():
		n.position = Vector2(radius * cos(theta) ,radius * sin(theta))
		radius += 16
