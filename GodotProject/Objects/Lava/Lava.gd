extends Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var time =0

var y0

# Called when the node enters the scene tree for the first time.
func _ready():
	y0 = position.y
	
func _physics_process(delta):
	time += delta
	
	position.y = y0 + 13 * cos(1.5 * time)
	
	rotation =  PI * cos(1.5 * time) / 800
	


func _on_Lava_item_rect_changed():
	material.set_shader_param("ratiox",scale.x)
	material.set_shader_param("ratioy",scale.y)

