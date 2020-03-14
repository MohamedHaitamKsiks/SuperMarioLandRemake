extends Area2D

signal destroy_coin

var destroy = false

func _ready():
	pass

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()


func _on_Coin_destroy_coin():
	if not destroy :
		destroy = true
		$AnimationPlayer.play("destroy")
		$CollisionShape2D.disabled = true
		Scores.coins += 1
