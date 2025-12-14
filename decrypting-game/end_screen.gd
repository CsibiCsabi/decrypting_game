extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Score.text = str(Gs.points)
	$HighScore.text = str(Gs.highScore)

func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level.tscn")

func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
