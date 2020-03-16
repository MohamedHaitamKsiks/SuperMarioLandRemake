extends KinematicBody2D

signal destroy(mario)

#item type
export var type = 0
var velocity = Vector2(0,0)
const FLOOR = Vector2(0,-1)

func _ready():
	$AnimatedSprite.frame = type

func _physics_process(delta):
	#applicate gravity
	gravity() 
	if is_on_floor() and type == 2:#if the item is a mushroom 
		velocity.y = -50
	if is_on_wall() :
		velocity.x = -velocity.x
	velocity.y = move_and_slide(velocity,FLOOR).y
	
	#strech
	$AnimatedSprite.scale.x = 1 - 0.1*abs(velocity.y)/ 50
	$AnimatedSprite.scale.y = 1 + 0.1*abs(velocity.y)/ 50
	
func gravity():
	velocity.y += 5


func _on_Item_destroy(mario):
	if type == 0 and Scores.health < 3:#mushroom
		Scores.health += 1
	queue_free()
