extends Area2D


signal raise_flag(mario)
var mario


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_FinalFlag_raise_flag(mario):
	$AnimationPlayer.play("raise_flag")
	self.mario = mario 


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "raise_flag" :
		mario.emit_signal("finish_level")
