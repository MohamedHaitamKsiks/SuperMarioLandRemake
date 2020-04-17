extends Area2D


# Declare member variables here. Examples:
var mario


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_DestroyButton_body_entered(body):
	if "Mario" in body.name and $AnimatedSprite.animation != "activate":
		$AnimatedSprite.play("activate")
		mario = body
		mario.emit_signal("shake_camera",8,0.4,0.1)
		$SFXActivate.play()
		if get_parent().has_node("Bowser"):
			get_parent().get_node("Bowser").get_node("DieTimer").wait_time = 5.5
			get_parent().get_node("Bowser").health = 0
			get_parent().get_node("Bowser").emit_signal("cappy_kill",self)


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "activate" :
		get_node("DestructibleSolid").emit_signal("destroy",mario)
