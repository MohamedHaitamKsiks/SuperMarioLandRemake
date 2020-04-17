extends "res://Objects/Enemies/EnemyParent.gd"


var shell = false
var speed = 30
var rot = 0
var Mario

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity.x = speed
	set_physics_process(false)

func _physics_process(delta):
	velocity = move(velocity)
	fall(6,200)
	if on_wall() or (not $RayCast2D.is_colliding() and ground):
		if $AnimatedSprite.flip_h :
			velocity.x = speed
			$RayCast2D.position.x = 6
		else :
			velocity.x = -speed
			$RayCast2D.position.x = -6
		if shell :
			$SFXWallCollision.play()
			$AnimatedSprite.scale.x *= -1
		$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
	
	
	if shell:
		if not die :
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
		$DestroyTimer.start()
		destory()
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
		$SFXDie.play()
		$AnimatedSprite.play("die")
		self.Mario = mario
	else :
		if velocity.x == 0:
			speed = 20 * (self.global_position.x - mario.global_position.x)
			velocity.x = speed
			$SFXWallCollision.play()
		else :
			velocity.x = 0
			speed = 0
			$SFXWallCollision.play()


func _on_Shell_body_entered(body):
	if body != self and velocity.x != 0 and shell:
		if "Goomba" in body.name or "Koopa" in body.name :
			body.emit_signal("cappy_kill",self)
			Mario.emit_signal("shake_camera",8,0.2,0.1)
			


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "die":
		$AnimatedSprite.play("shell")


func _on_DestroyTimer_timeout():
	queue_free()
	var node = Coin.instance()
	get_parent().add_child(node)
	node.global_position = self.global_position
	node.emit_signal("destroy_coin")

