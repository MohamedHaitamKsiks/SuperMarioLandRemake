extends Area2D


signal destroy_star
var destroy = false
var enable = true
export var id = 0
const WaveEffect = preload("res://Objects/Particles/WaveEffect/WaveEffect.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if Scores.level_stars[Scores.level_id][id]:
		enable = false
	$SFXstar.play()
	$AnimationPlayer.play("default")

func _process(delta):
	if not enable:
		$AnimatedSprite.modulate = Color(0.1,0.2,1,0.6)


#Wave Effect
func wave_effect(force):
	var node = WaveEffect.instance()
	get_parent().add_child(node)
	node.position = self.global_position
	node.scale = Vector2(force,force)


func _on_Star_destroy_star():
	if not destroy :
		destroy = true
		$AnimationPlayer.play("destroy")
		$AnimatedSprite.play("destroy")
		$CollisionShape2D.disabled = true
		$SFXcollect.play()
		$SFXstar.stop()
		


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "destroy":
		wave_effect(1)
		$SFXDestroy.play()
		if enable :
			Scores.stars += 1
			Scores.level_stars[Scores.level_id][id] = true
		


func _on_SFXDestroy_finished():
	queue_free()
