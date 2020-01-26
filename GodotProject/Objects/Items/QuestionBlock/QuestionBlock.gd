extends StaticBody2D


export var items = Array()
signal get_item(smash)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_AnimationPlayer_animation_finished(anim_name):
	if len(items) == 0:
		$AnimatedSprite.frame = 2


func _on_QuestionBlock_get_item(smash):
	if not smash:
		$AnimationPlayer.play("GetItem")
	else :
		$AnimationPlayer.play("GetItemSmash")
	if len(items) > 0 :
		Scores.coins += 1
		items.remove(0)
