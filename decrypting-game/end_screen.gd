extends Control

@onready var score: Label = %Score
@onready var high_score: Label = %HighScore

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(Gs.points)
	score.text = "Score: " + str(Gs.points)
	high_score.text = "High Score: " + str(Gs.highScore)

func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file("res://ui.tscn")

func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
