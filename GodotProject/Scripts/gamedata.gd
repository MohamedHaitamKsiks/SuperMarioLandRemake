extends Node


func _ready():
	pass


func create_save_file():
	Scores.coins = 0
	Scores.stars = 0
	Scores.lives = 3
	
	Scores.level_id = -1

	var i = 0
	for k in Scores.level_path :
		Scores.level_stars[i] = [false,false,false]
		i+=1
	
	save_game()
		
	
func save_game():
	var save_game = File.new()
	save_game.open("user://savegame.save",File.WRITE)
	
	save_game.store_line(to_json(Scores.coins))
	save_game.store_line(to_json(Scores.stars))
	save_game.store_line(to_json(Scores.lives))
	save_game.store_line(to_json(Scores.level_id))
	save_game.store_line(to_json(Scores.level_stars))
	
	save_game.close()
	
func load_game():
	
	var save_game = File.new()
	save_game.open("user://savegame.save",File.READ)
	
	if not save_game.file_exists("user://savegame.save"):
		return false
	
	Scores.coins = int(save_game.get_line())
	Scores.stars = int(save_game.get_line())
	Scores.lives = int(save_game.get_line())
	Scores.level_id = int(save_game.get_line())
	var level_stars =  parse_json(save_game.get_line())
	for i in range(len(level_stars)):
		Scores.level_stars[i] = level_stars[i]
	
	save_game.close()
	
	return true
