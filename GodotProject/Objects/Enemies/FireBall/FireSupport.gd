extends Sprite

var Fireball = preload("res://Objects/Enemies/FireBall/Fireball.tscn")

export var period = 0
export var phi = 0
export var number_of_fireball = 0

var theta = 0
var time = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	for k in range(number_of_fireball):
		var fire = Fireball.instance()
		add_child(fire)

func _physics_process(delta):
	time += delta
	
	theta = 2 * PI * time / period + phi
	
	var radius = 0
	
	for n in get_children():
		n.position = Vector2(radius * cos(theta) ,radius * sin(theta))
		radius += 16
