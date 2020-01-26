extends CanvasLayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var blur = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("start")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	draw_coins_counter()
	draw_health()
	draw_blur()

func draw_blur():
	$Blur/BlurRect.get_material().set_shader_param("lod",blur)


func draw_coins_counter():
	var coins = Scores.coins
	var res = str(int(coins / 10))+" "+str(coins % 10)
	$CoinCounter/Label.text = res
	
func draw_health():
	var health = Scores.health
	if health == 3 : 
		$Health/ColorRect.rect_scale = Vector2(1,1)
	elif health == 2 : 
		$Health/ColorRect.rect_scale = Vector2(0.66,0.66)
	elif health == 1 : 
		$Health/ColorRect.rect_scale = Vector2(0.33,0.33)
	else :
		$Health/ColorRect.rect_scale = Vector2(0,0)