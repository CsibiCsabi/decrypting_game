extends Node

var lives = 5

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
		
	

func end():
	checkHighScore()
	#go to end screen!
	print("end stuff...")
