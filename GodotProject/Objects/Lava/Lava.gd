extends Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var time =0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _physics_process(delta):
	pass


func _on_Lava_item_rect_changed():
	material.set_shader_param("ratiox",scale.x)
	material.set_shader_param("ratioy",scale.y)

