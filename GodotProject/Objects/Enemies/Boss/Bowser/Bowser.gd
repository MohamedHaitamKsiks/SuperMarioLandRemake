extends "res://Objects/Enemies/EnemyParent.gd"


var Firebreath = preload("res://Objects/Enemies/Boss/Bowser/Firebreath.tscn")
var Goomba = preload("res://Objects/Enemies/Goomba/Goomba.tscn")


var prepareJump = false
var direction = 1
var jump = false
var blink = 0
var hit = false

var Mario

var gravity = 9


# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.start()
	health = 5
	
	Mario = get_parent().get_parent().get_node("Mario")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	fall(gravity,300)
	
	if ground :
		if jump and velocity.y > 0:
			velocity.x = 0
			$AnimatedSprite.play("std")
			jump = false
			Mario.emit_signal("shake_camera",6,0.4,0.1)
			$SFXStep.play()
			$Timer.start()
	
	if die :
		$AnimatedSprite.play("die")
		
	if hit:
		$AnimatedSprite.material.set_shader_param("inten",1.0)	
	else :
		$AnimatedSprite.material.set_shader_param("inten",0.0)	
	
	move(velocity)
	$AnimatedSprite.scale = Vector2(1 - 0.15 * abs(velocity.y/300) * int(not ground) , 1 + 0.15 * abs(velocity.y/300) * int(not ground))
	

func _on_Timer_timeout():
	var attack = round(rand_range(0,1))
	if not die :
		if attack == 0:
			$AnimatedSprite.play("prepareJump")
		else :
			$AnimatedSprite.play("firebreath")


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "prepareJump":
		if not jump:
			$AnimatedSprite.play("jump")
			velocity.y = -300
			velocity.x = direction * rand_range(50,100)
			direction *= -1
			jump = true
	elif $AnimatedSprite.animation == "firebreath":
		$AnimatedSprite.play("std")
		$Timer.start()

func _on_AnimatedSprite_frame_changed():
	if $AnimatedSprite.animation == "firebreath":
		if $AnimatedSprite.frame == 6:
			var fire = Firebreath.instance()
			get_parent().add_child(fire)
			fire.global_position = $Position2D.global_position
			fire.speed = -180
			Mario.emit_signal("shake_camera",6,0.4,0.1)
			
	if $AnimatedSprite.animation == "die":
		if $AnimatedSprite.frame == 1:
			if blink >=2:
				$AnimatedSprite.frame = 0
				return
			$SFXBlink.play()
			blink += 1


func _on_Bowser_cappy_kill(cappy):
	if not die :
		hit = true
		$HitTimer.start()	
		if health > 1:
			health -= 1
			Mario.emit_signal("shake_camera",8,0.4,0.1)
		else :
			die = true
			velocity.y = 0
			velocity.x = 0
			gravity = 0
			$FallTimer.start()
			get_parent().get_parent().get_node("Music").stop()
			$DieTimer.start()
			Mario.emit_signal("shake_camera",8,2,0.1)


func _on_DieTimer_timeout():
	queue_free()
	var goomba = Goomba.instance()
	get_parent().add_child(goomba)
	goomba.global_position = global_position
	goomba.get_node("DestParticles").emitting = true
	goomba.emit_signal("cappy_kill",self)
	goomba.velocity.y = -350
	
	get_parent().get_node("Pipe").teleport_enable = true
	get_parent().get_node("Pipe").position.x -= 32 


func _on_HitTimer_timeout():
	hit = false


func _on_FallTimer_timeout():
	gravity = 9
	$SFXFall.play()
