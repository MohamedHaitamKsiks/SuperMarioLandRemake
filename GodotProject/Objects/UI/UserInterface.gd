extends CanvasLayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var blur = 0
var time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("start")
	$ColorRect.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	draw_coins_counter()
	draw_health()
	draw_blur()
	draw_star()
	$ColorRect/Title.text = get_parent().title
	
	time += delta



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
	if health <= 1:
		$Health.position.y = 10 * abs(sin(10*time))
	
	

func draw_star():
	for k in range(3):
		$StarsCounter.get_node("Star"+str(k+1)).region_rect = Rect2(32 * int(Scores.level_stars[Scores.level_id][k]),0,32,32)


func _on_AnimationPlayer_animation_finished(anim_name):
	get_parent().get_node("Music").play()
