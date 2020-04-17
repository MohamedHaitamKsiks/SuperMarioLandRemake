extends PathFollow2D


export var speed = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	offset += speed * delta
