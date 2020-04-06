extends Area2D


# Declare member variables here. Examples:
export var text = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Label/Label.text = text
	$Label/LabelShadow.text = text


func _on_Help_body_entered(body):
	if "Mario" in body.name:
		$AnimationPlayer.play("fadeIN")


func _on_Help_body_exited(body):
	if "Mario" in body.name:
		$AnimationPlayer.play("fadeOut")
