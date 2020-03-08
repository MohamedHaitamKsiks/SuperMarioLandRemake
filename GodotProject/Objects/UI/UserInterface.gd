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
	var res = ""
	var digit = 3
	
	for k in range(digit):
		res += str(int( coins / pow(10,digit - k - 1) ))
		coins = coins % int(pow(10,digit - k -1 ))
	$CoinCounter/Label.text = res
	$CoinCounter/Label2.text = res
	
func draw_health():
	var health = Scores.health
	$Health/AnimatedSprite.frame = 3 - health
