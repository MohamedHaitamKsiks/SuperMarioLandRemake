extends KinematicBody2D

var Coin = preload("res://Objects/Items/Coin/Coin.tscn")

var health = 1
var die = false
var velocity = Vector2(0,0)
var ground
var rot_speed = 0
const FLOOR = Vector2(0,-1)
signal kill(mario)
signal cappy_kill(cappy)

func move(velocity):
	return move_and_slide(velocity,FLOOR)
	
func fall(gravity,max_vspeed):
	if (not is_on_floor()):
		velocity.y += gravity 
		ground = false
	else :
		ground = true
	if velocity.y > max_vspeed :
		velocity.y = max_vspeed
		
func on_wall():
	return is_on_wall()

func destory():
	var node = Coin.instance()
	get_parent().add_child(node)
	node.global_position = self.global_position
	node.emit_signal("destroy_coin")
