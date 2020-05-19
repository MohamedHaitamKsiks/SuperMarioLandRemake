extends Area2D

export var enable = true
export var period = 1
export var start = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.frame = 13
	$CollisionShape2D.disabled = true
	
	
func _process(delta):
	pass
	
	

func _on_StartTimer_timeout():
	if enable :
		$AnimatedSprite.frame = 0
		$AnimatedSprite.play("default")


func _on_PeriodTimer_timeout():
	if not ($RayCast2D.is_colliding() or $RayCast2D2.is_colliding()) :
		$AnimatedSprite.frame = 0
		return
	$PeriodTimer.start()


func _on_AnimatedSprite_animation_finished():
	$PeriodTimer.start()


func _on_AnimatedSprite_frame_changed():
	if $AnimatedSprite.frame == 0:
		$SFXIO.play()
	if $AnimatedSprite.frame == 2:
		$CollisionShape2D.disabled = false
	if $AnimatedSprite.frame == 5:
		$SFXAttack.play()
	if $AnimatedSprite.frame == 6:
		$SFXAttack.stop()
	if $AnimatedSprite.frame == 7:
		$SFXAttack.play()
	if $AnimatedSprite.frame == 8:
		$SFXAttack.stop()
	if $AnimatedSprite.frame == 11:
		$SFXIO.play()
		$CollisionShape2D.disabled = true
		
