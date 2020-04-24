extends StaticBody2D

export var plant_enable = true
export var teleport_enable = false
export var period = 1
export var start = 0
export var out_speed = 50
export var underworld_music = false
export var overworld_music = false

var can_teleport = true

var button_to_enter = "gameplay_down"
var Mario

var time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Piranha.enable = plant_enable
	$Piranha.period = period
	$Piranha.start = start
	
	var angle = int(round(transform.get_rotation() * 180 /PI)) % 360
	
	while angle <0:
		angle += 360
	
	if angle == 0:
		button_to_enter = "gameplay_down"
	elif angle == 90:
		button_to_enter = "left"
	elif angle == 180:
		button_to_enter = "up"
	elif angle == 270:
		button_to_enter = "right"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
		
	if teleport_enable and $RayCast2D.is_colliding() and "Mario" in $RayCast2D.get_collider().name:
		if not $enter.visible:
			time = 0
		$enter.visible = true		
	else:
		$enter.visible = false
		
	$enter.position.y = 6 * cos(4*time) - 86
	$enter.modulate = Color(1.0,1.0,1.0,1 - exp(-time))	
		
		
	if teleport_enable and $RayCast2D.is_colliding() and "Mario" in $RayCast2D.get_collider().name and Input.is_action_just_pressed(button_to_enter):
		Mario = $RayCast2D.get_collider()
		if not Mario.teleport :
			Mario.velocity = Vector2(0,0)
			Mario.teleport = true
			Mario.teleport_angle =  transform.get_rotation() + PI/2
			$TeleportTimer.start()
			$SFXPipeEntered.play()
			can_teleport = false
			if underworld_music or overworld_music :
				get_parent().get_parent().get_node("Music").stop()
				get_parent().get_parent().get_node("UnderworldMusic").stop()
				get_parent().get_parent().get_node("Transition").get_node("AnimationPlayer").play("teleport")

func _on_TeleportTimer_timeout():
	Mario.teleport = false
	
	Mario.global_position = self.get_node("PipeOut").get_node("Position2D").global_position
	self.get_node("PipeOut").get_node("DestParticles").emitting = true
	Mario.velocity = Vector2(-cos(get_node("PipeOut").transform.get_rotation() + transform.get_rotation() + PI/2) * get_node("PipeOut").out_speed ,-sin(get_node("PipeOut").transform.get_rotation() + transform.get_rotation() + PI/2) * get_node("PipeOut").out_speed)
	if Mario.velocity.x == 0:
		Mario.jump = true
	else :
		Mario.dive = true
	Mario.get_node("SFXJump").play()
	Mario.emit_signal("shake_camera",8,0.2,0.5)
	can_teleport = true
	if overworld_music:
		 get_parent().get_parent().get_node("Music").play()
	if underworld_music:
		 get_parent().get_parent().get_node("UnderworldMusic").play()
		
