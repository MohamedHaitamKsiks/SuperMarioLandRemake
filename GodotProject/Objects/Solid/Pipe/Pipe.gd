extends StaticBody2D

export var plant_enable = true
export var teleport_enable = false
export var period = 1
export var start = 0
export var out_speed = 50

var button_to_enter = "ui_down"
var Mario

# Called when the node enters the scene tree for the first time.
func _ready():
	$Piranha.enable = plant_enable
	$Piranha.period = period
	$Piranha.start = start
	
	var angle = int(round(transform.get_rotation() * 180 /PI)) % 360
	
	while angle <0:
		angle += 360
	
	if angle == 0:
		button_to_enter = "ui_down"
	elif angle == 90:
		button_to_enter = "ui_left"
	elif angle == 180:
		button_to_enter = "ui_up"
	elif angle == 270:
		button_to_enter = "ui_right"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if teleport_enable and $RayCast2D.is_colliding() and "Mario" in $RayCast2D.get_collider().name and Input.is_action_just_pressed(button_to_enter):
		Mario = $RayCast2D.get_collider()
		Mario.velocity = Vector2(0,0)
		if not Mario.teleport :
			Mario.teleport = true
			Mario.teleport_angle =  transform.get_rotation() + PI/2
			$TeleportTimer.start()
			$SFXPipeEntered.play()
		

func _on_TeleportTimer_timeout():
	Mario.teleport = false
	Mario.global_position = self.get_node("PipeOut").get_node("Position2D").global_position
	Mario.velocity = Vector2(-cos(get_node("PipeOut").transform.get_rotation() + transform.get_rotation() + PI/2) * get_node("PipeOut").out_speed ,-sin(get_node("PipeOut").transform.get_rotation() + transform.get_rotation() + PI/2) * get_node("PipeOut").out_speed)
	if Mario.velocity.x == 0:
		Mario.jump = true
	else :
		Mario.dive = true
	Mario.get_node("SFXJump").play()
	Mario.emit_signal("shake_camera",8,0.2,0.5)
