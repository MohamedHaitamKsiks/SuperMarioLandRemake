extends CanvasLayer

export var blur = float(0.0)
signal start

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	draw_blur()

func draw_blur():
	$BlurRect.get_material().set_shader_param("lod",blur)

func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_DeadUI_start():
	$AnimationPlayer.play("start")
	$SFXDie.play()
	Scores.health = 3
	get_tree().paused = true
