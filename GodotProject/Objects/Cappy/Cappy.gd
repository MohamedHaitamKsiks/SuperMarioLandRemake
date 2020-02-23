extends KinematicBody2D


var back = false
var mario
var angle
var speed = 0
var velocity = Vector2(0,0)

signal jump

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _physics_process(delta):
	
	$AnimatedSprite.scale.y = 1 - abs(velocity.x / 500) * 0.3
	$AnimatedSprite.scale.x = 1 + abs(velocity.x / 500) * 0.3
	
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
				$CollisionShape2D.disabled = true
		
		
	move_and_slide(velocity)





func _on_BackArea_body_entered(body):
	if back and "Mario" in body.name :
		body.emit_signal("get_back_cappy")
		queue_free()
	if "Goomba" in body.name :
		body.emit_signal("cappy_kill")
		back = true
		$CollisionShape2D.disabled = true
		mario.emit_signal("shake_camera",8,0.4,0.1)


func _on_Timer_timeout():
	back = true
	$CollisionShape2D.disabled = true


func _on_Cappy_jump():
	$AnimationPlayer.play("jump")
