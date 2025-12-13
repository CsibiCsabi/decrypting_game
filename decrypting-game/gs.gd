extends Node

var lives = 5

var multiplier : float = 1

var points = 0

func lose_hp(amount : int):
	lives -= amount
	refresh()

func restart():
	lives = 5
	refresh()

func refresh():
	multiplier = pow(1.2, (5-lives))
	print(multiplier)
