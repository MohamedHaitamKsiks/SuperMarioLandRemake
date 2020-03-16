extends "res://Objects/Enemies/EnemyParent.gd"


var shell = false
var speed = 20
var rot = 0
var Mario

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity.x = 20

func _process(delta):
	velocity = move(velocity)
	fall(6,200)
	if on_wall() :
		if $AnimatedSprite.flip_h :
			velocity.x = speed
		else :
			velocity.x = -speed
		$SFXWallCollision.play()
		$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
	
	
	if shell:
		if not die :
			$Shell/CollisionShape2D.scale.x = 2 * int(velocity.x != 0)
			if $AnimatedSprite.animation == "shell":
				$AnimatedSprite.speed_scale = abs(velocity.x)/70
		
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Koopa_cappy_kill(cappy):
	if not shell:
		velocity.x = cappy.velocity.x/5
		$AnimatedSprite.rotate(sign(velocity.x))
		velocity.y = -50
		shell = true
		die = true
		$CollisionShape2D.queue_free()
		$Shell/CollisionShape2D.queue_free()
		$AnimatedSprite.flip_v = true
		$SFXDie.play()
		$AnimatedSprite.play("shell")		
	else : 
		speed = cappy.velocity.x/4
		velocity.x = speed
		$SFXWallCollision.play()
		$AnimatedSprite.play("shell")
		


func _on_Koopa_kill(mario):
	$AnimationPlayer.play("squash")
	if not shell :
		velocity.x = 0
		speed = 0
		shell = true
		$SFXWallCollision.play()
		$AnimatedSprite.play("die")
		self.Mario = mario
	else :
		speed = 30 * (self.global_position.x - mario.global_position.x)
		velocity.x = speed
		$SFXWallCollision.play()


func _on_Shell_body_entered(body):
	if body != self :
		if "Goomba" in body.name or "Koopa" in body.name :
			body.emit_signal("cappy_kill",self)
			Mario.emit_signal("shake_camera",8,0.2,0.1)
			


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "die":
		$AnimatedSprite.play("shell")
