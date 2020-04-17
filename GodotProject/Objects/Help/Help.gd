extends Area2D


# Declare member variables here. Examples:
export var text = ""

export var image_enable = false
export var image_path = ""

export var button_enable = false
export var button = ""


export var level_id = -1
export var star_counter = false

export var stars_required = 0

var image

# Called when the node enters the scene tree for the first time.
func _ready():	
	if image_enable :
		image = load(image_path)
		var sprite = Sprite.new()
		sprite.texture = image
		sprite.offset.y = -140
		$Label.add_child(sprite)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if star_counter :
		$Label/StarsCounter.visible = true
		for i in range(3):
			$Label/StarsCounter.get_node("Star"+str(i+1)).region_rect = Rect2(32 * int(Scores.level_stars[level_id][i]),0,32,32)
			$Label/StarsCounter.get_node("StarShadow"+str(i+1)).region_rect = Rect2(32 * int(Scores.level_stars[level_id][i]),0,32,32)
	
	if button_enable :
		var btext = InputMap.get_action_list(button)[0].as_text()
		$Label/Label.text = text + '\n' + "press" + " - " + btext + " -"
		$Label/LabelShadow.text = text + '\n' + "press" +  " - " + btext + " -"
		return
		
	if stars_required > 0 :
		$Label/starcounter/Counter.text = "X " + str(stars_required)
		$Label/starcounter/CounterShadow.text = "X " + str(stars_required)
		$Label/starcounter.visible = true
		
	$Label/Label.text = text
	$Label/LabelShadow.text = text
	

func _on_Help_body_entered(body):
	if "Mario" in body.name:
		$AnimationPlayer.play("fadeIN")


func _on_Help_body_exited(body):
	if "Mario" in body.name:
		$AnimationPlayer.play("fadeOut")
