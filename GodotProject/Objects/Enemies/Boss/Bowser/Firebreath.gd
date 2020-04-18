extends Area2D


export var speed = 50


# Called when the node enters the scene tree for the first time.
func _ready():
	$SFXfFire.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x += speed * delta


func _on_Timer_timeout():
	queue_free()
