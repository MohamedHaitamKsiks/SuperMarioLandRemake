extends CanvasLayer


export var gamepad = 0

var controls_list = ["gameplay_jump","gameplay_sprint","gameplay_throwcappy","gameplay_dive","gameplay_down"]
var controler_list = ["A","B","X","Y"]

var select = 0

var wait_input = false

var can_press = true

var button_group = []

var last_focus
func _ready():
	for n in $ScrollContainer/Controls.get_children():
		if n.get_class() == "Button":
			button_group.append(n)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Blur.visible = $ScrollContainer.visible
	if $ScrollContainer.visible :
		draw_controls()
	

func draw_controls():
	var k = 0
	for n in $ScrollContainer/Controls.get_children():
		if k == 0:
			if gamepad == 1:
				$ScrollContainer/Controls/SubOption.text = "Gamepad"
		elif k <=5 :
			var btext
			var button = controls_list[k-1]
			if gamepad == 1:
				var button_index = InputMap.get_action_list(button)[1].button_index
				if button_index < 4 :
					btext = controler_list[button_index]
				else:
					btext =  Input.get_joy_button_string(button_index)
			else :
				btext =InputMap.get_action_list(button)[0].as_text()
				
			if wait_input and select == k-1:
				n.get_node("HBoxContainer").get_node("Label").text = "press a new button"
			else:
				n.get_node("HBoxContainer").get_node("Label").text = btext
		k+=1



func store_action(event,action):
	var stored_event = InputMap.get_action_list(action)[1 - gamepad]
	InputMap.action_erase_events(action)
	for k in range(2):
		if k == gamepad:
			InputMap.action_add_event(action,event)
		else:
			InputMap.action_add_event(action,stored_event)


func _input(event):
	if $ScrollContainer.visible:
		if wait_input:
			if event is InputEventKey and event.is_pressed() and gamepad == 0:
				store_action(event,controls_list[select])
				wait_input = false
			elif event is InputEventJoypadButton and event.is_pressed() and gamepad == 1:
				store_action(event,controls_list[select])
				wait_input = false
		else :
			if event.is_action_pressed("down"):
				select += 1
			if event.is_action_pressed("up"):
				select -= 1
				
			if select < 0:
				select = 5
			if select > 5:
				select = 0
			if not button_group[select].has_focus():
				button_group[select].grab_focus()
				
			if event.is_action_pressed("ui_accept") and select < 5:
				wait_input = true


func _on_Back_pressed():
	last_focus.grab_focus()
	$ScrollContainer.visible = false
	get_parent().controls = false
