extends Node

var start_lives: int = 5
var lives: int = start_lives
var multiplier : float = 1
var points : int = 0
var highScore = 0

func lose_hp(amount : int):
	lives -= amount
	refresh()

func restart():
	lives = 5
	refresh()

func refresh():
	multiplier = pow(1.3, (5-lives))
	print(multiplier)

func checkHighScore():
	if points > highScore:
		highScore = points


func checkifend():
	if Gs.lives <= 0:
		end()

func end():
	checkHighScore()
	lives = start_lives
	get_tree().change_scene_to_file("res://end_screen.tscn")
	print("ended")
