extends Area2D


# Declare member variables here. Examples:
export var text = ""

export var image_path = ""

export var stars_required = 0

export var enable = false
export var level_id = -1

export var goto_next_world = false

var mario

var collision = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if enable or goto_next_world:
		$Help.visible = true
		$Help.star_counter = not goto_next_world
	else :
		$Help.queue_free()
	if Scores.stars < stars_required :
		enable = false
		$Help.text = "Locked"
		$Help.star_counter = false
		$Help.button_enable = false
		$Help.stars_required = stars_required
	else:	
		$Help.text = text
		$Help.image_path = image_path
		$Help.level_id = level_id
		$Help.stars_required = -1
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept") and enable and collision :
		mario.emit_signal("start_level",Scores.level_path[level_id])
		Scores.level_id = level_id
		
func _on_Destination_body_entered(body):
	if "Mario" in body.name :
		collision = true
		body.global_position = global_position
		body.velocity = Vector2(0,0)
		mario = body


func _on_Destination_body_exited(body):
	if "Mario" in body.name :
		collision = false
		
