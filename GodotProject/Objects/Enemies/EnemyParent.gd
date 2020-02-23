extends KinematicBody2D

var health = 1
var die = false
var velocity = Vector2(0,0)
const FLOOR = Vector2(0,-1)
signal kill(mario)
signal cappy_kill()

func move(velocity):
	return move_and_slide(velocity,FLOOR)
	
func fall(gravity,max_vspeed):
	if (not is_on_floor()):
		velocity.y += gravity 
	if velocity.y > max_vspeed :
		velocity.y = max_vspeed
		
func on_wall():
	return is_on_wall()
