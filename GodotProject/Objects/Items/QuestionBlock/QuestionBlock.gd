extends StaticBody2D

#preload class
var Coin = preload("res://Objects/Items/Coin/Coin.tscn")
var Item = preload("res://Objects/Items/Item/Item.tscn")
var velocity = Vector2(0,0)

var jump = false

export var items = PoolIntArray()
export var type = 0

signal get_item(smash)

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.frame = type
	
func _process(delta):
	pass

func _on_AnimationPlayer_animation_finished(anim_name):
	if len(items) == 0:
		$AnimatedSprite.frame = 2
	else :
		$AnimatedSprite.frame = type
	jump = false

func _on_QuestionBlock_get_item(smash):
	if len(items) > 0:
		$AnimatedSprite.frame = 0
	if not smash:
		$AnimationPlayer.play("GetItem")
		jump = true
	else :
		$AnimationPlayer.play("GetItemSmash")
		
	if len(items) > 0 :
		if items[0] == 0:#it is a coin
			var node = Coin.instance()
			$ItemInstancingPosition.add_child(node)
			node.emit_signal("destroy_coin")
		else:
			var node = Item.instance()
			$ItemInstancingPosition.add_child(node)
			node.type = items[0] - 1
			node.velocity.y = -110
		
			
		items.remove(0)


func _on_KillArea_body_entered(body):
	for enemy in EnemyList.enemy_body:
		if enemy in body.name :
			body.emit_signal("cappy_kill",self)
