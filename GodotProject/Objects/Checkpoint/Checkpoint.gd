extends Area2D

export var checkpoint_id = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if Scores.checkpoint >= checkpoint_id:
		$CollisionShape2D.disabled = true
		$AnimatedSprite.frame = 6 




func _on_Checkpoint_body_entered(body):
	if "Mario" in body.name:
		$AnimatedSprite.play("default")
		Scores.checkpoint = checkpoint_id
		$SFXCheckpoint.play()
		$CollisionShape2D.queue_free()
		
