extends KinematicBody2D


var back = false
var mario
var angle
var speed = 0
var velocity = Vector2(0,0)

signal jump





func _physics_process(delta):
	
	$AnimatedSprite.scale.y = 1 - abs(velocity.x / 500) * 0.3
	$AnimatedSprite.scale.x = 1 + abs(velocity.x / 500) * 0.3
	
	$AnimationPlayerTurning.play("New Anim")
	
	if back : 
		angle = atan2(mario.global_position.y - global_position.y , mario.global_position.x - global_position.x)
		speed += 60
		velocity = Vector2(speed * cos(angle) , speed * sin(angle))
		$AnimatedSprite.rotation = angle + PI * int(velocity.x < 0)
	else :
		velocity.x -= sign(velocity.x) * 20
		if abs(velocity.x) <= 0.2:
			velocity.x = 0
			#back
			if(not Input.is_action_pressed("gameplay_throwcappy") and not back):
				back = true
				$SFXTurning.play()
				$SFXTurning.pitch_scale = 1
				$CollisionShape2D.disabled = true		
	move_and_slide(velocity)
	$SFXTurning.pitch_scale += 0.01


func _on_BackArea_body_entered(body):
	if back and "Mario" in body.name :
		body.emit_signal("get_back_cappy")
		queue_free()

	if	not back and "QuestionBlock" in body.name : 
		body.emit_signal("get_item",true)
		mario.emit_signal("shake_camera",4,0.4,0.1)
	
	if not back and "Brick" in body.name:
		body.emit_signal("destroy")
		mario.emit_signal("shake_camera",8,0.4,0.1)
	
	for enemy in EnemyList.enemy_body:
		if not back and (enemy in body.name ):
			back = true
			body.emit_signal("cappy_kill",self)
			$CollisionShape2D.disabled = true
			mario.emit_signal("shake_camera",8,0.4,0.1)


func _on_Timer_timeout():
	back = true
	$CollisionShape2D.disabled = true
	

func _on_Cappy_jump():
	$AnimationPlayer.play("jump")

