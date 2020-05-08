extends KinematicBody2D

signal destroy(mario)

#item type
export var type = 0
var time = 0
var velocity = Vector2(0,0)
const FLOOR = Vector2(0,-1)

func _ready():
	$AnimatedSprite.frame = type
	$AnimatedSprite.scale = Vector2(0,0)

func _physics_process(delta):
	#applicate gravity
	$AnimatedSprite.frame = type
	gravity() 
	if is_on_floor() and velocity.x == 0:#if the item is a mushroom 
		velocity.x = 50
	if is_on_wall() :
		velocity.x = -velocity.x
	velocity.y = move_and_slide(velocity,FLOOR).y
	
	if velocity.y == 0:
		$CollisionShape2D.disabled = false
	
	#strech
	$AnimatedSprite.scale.x = 1 - 0.1*abs(velocity.y)/ 200
	$AnimatedSprite.scale.y = 1 + 0.1*abs(velocity.y)/ 200
	
	$AnimatedSprite.scale = Vector2(1,1) * (1.0 - exp(-10*time) + 0.2*exp(-2*time))
	
	if not $CollisionShape2D.disabled and $RayCast2D.is_colliding() and "QuestionBlock" in $RayCast2D.get_collider().name:
		var block = $RayCast2D.get_collider()
		if block.jump :
			velocity.y = -50
			velocity.x = -velocity.x
	
	time += delta
	
func gravity():
	if velocity.y < 200:
		velocity.y += 5


func _on_Item_destroy(mario):
	if type == 0 and Scores.health < 3:#mushroom
		Scores.health += 1
	else :
		Scores.lives += 1
	queue_free()
