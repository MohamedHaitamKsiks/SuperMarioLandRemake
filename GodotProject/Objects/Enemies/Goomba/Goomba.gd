extends "res://Objects/Enemies/EnemyParent.gd"

# Declare member variables here. Examples:
# var a = 2
var Mario
var Cappy
# Called when the node enters the scene tree for the first time.
func _ready():
	velocity.x = 20

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = move(velocity)
	if not die:
		fall(7,200)
		if on_wall() :
			$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
			$AnimatedSprite.play("turn")
			if $AnimatedSprite.flip_h:
				velocity.x = -20
			else :
				velocity.x = 20
	else :
		if not $AnimatedSprite.animation == "die":
			fall(6,200)
			rotate(rot_speed)


func _on_Goomba_kill(mario):
	$SFXDie.play()
	velocity.x = 0
	velocity.y = 0
	die = true
	$AnimatedSprite.play("die")
	$Timer.start()
	$CollisionShape2D.queue_free()
	Mario = mario


func _on_Goomba_cappy_kill(cappy):
	velocity.y = -50
	die = true
	$Timer.start()
	$SFXDie.play()
	rot_speed = 0.4 * ( sign(cappy.velocity.x) + int(cappy.velocity.x == 0) )
	velocity.x = 50 * sign(cappy.velocity.x)
	$AnimatedSprite.speed_scale = 0
	$AnimatedSprite.z_index = 10
	$AnimatedSprite.frame = 6
	$CollisionShape2D.queue_free()
	
	


func _on_Timer_timeout():
	$DestParticles.emitting = true
	$AnimatedSprite.visible = false
	$TimerParticle.start()
	$SFXImpact.play()
	if $AnimatedSprite.animation == "die":
		Mario.emit_signal("shake_camera",8,0.4,0.1)
		


func _on_TimerParticle_timeout():
	queue_free()


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "turn":
		$AnimatedSprite.play("walk")
