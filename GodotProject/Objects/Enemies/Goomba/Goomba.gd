extends "res://Objects/Enemies/EnemyParent.gd"

# Declare member variables here. Examples:
# var a = 2
var Mario
# Called when the node enters the scene tree for the first time.
func _ready():
	velocity.x = 20

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = move(velocity)
	if not die:
		fall(6,200)
		if on_wall() :
			$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
			if $AnimatedSprite.flip_h:
				velocity.x = -20
			else :
				velocity.x = 20


func _on_Goomba_kill(mario):
	velocity.x = 0
	velocity.y = 0
	die = true
	$AnimatedSprite.play("die")
	$Timer.start()
	$CollisionShape2D.queue_free()
	Mario = mario
	


func _on_Timer_timeout():
	$DestParticles.emitting = true
	$AnimatedSprite.visible = false
	$TimerParticle.start()
	Mario.emit_signal("shake_camera",8,0.4,0.1)


func _on_TimerParticle_timeout():
	queue_free()
