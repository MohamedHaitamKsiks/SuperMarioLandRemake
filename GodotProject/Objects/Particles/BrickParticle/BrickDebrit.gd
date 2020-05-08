extends Area2D


var velocity = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	$Sprite.rotation += 0.1 * sign(velocity.x)
	position += velocity * delta
	velocity.y += 8


func _on_BrickDebrit_body_entered(body):
	velocity.y = -velocity.y / 2
	$CollisionShape2D.queue_free()
