extends Control

@onready var hp_label: Label = %Hp
@onready var multiplier_label: Label = %Multiplier
@onready var english1_label: Label = %English1
@onready var english2_label: Label = %English2
@onready var gibberish1_label: Label = %Gibberish1
@onready var gibberish2_label: Label = %Gibberish2
@onready var task_label: Label = %Task
@onready var answer_field: LineEdit = %TextEdit
@onready var points_label: Label = %Points
@onready var bar_rect: ColorRect = %Bar

var sentences = [
	"I BUILD AND CREATE THE FUTURE",
	"YOU DESIGN AND CODE THE PROJECT",
	"YOU BUILD THE PROJECT AND WIN MOONSHOT",
	"I DESIGN THE WORLD AND THE FUTURE",
	"CREATE PROJECT AND SOLVE PROBLEM",
	"YOU AND I WIN MOONSHOT",
	"HACK CLUB IS THE FUTURE",
	"BUILD HACK CLUB TEAM PROJECT"
]
var words = {
	# Pronouns
	"I": "E", #3
	"YOU": "Y", #3
	
	# Hackathon theme
	"MOONSHOT": "BAGES", #2
	"HACK": "GAVK", #2
	"CLUB": "VLUM", #2
	
	# Essential verbs
	"BUILD": "BRUD", #3
	"CREATE": "KREET", #2
	"CODE": "KOD", #1
	"DESIGN": "DEZIN", #2
	"SOLVE": "ZOOV", # 1
	"WIN": "W", # 2
	
	# Nouns
	"WORLD": "ALMA", #1
	"TEAM": "TEM", #1
	"PROJECT": "BROV", #4
	"FUTURE": "QUTR", #2
	"PROBLEM" : "BRLOM", #1
	
	# Connectors
	"AND": "N", #6
	"THE": "E", #5
	"IS" : "S" #1
}

var task_sentences = [
	"DESIGN MOONSHOT",
	"YOU BUILD HACK CLUB",
	"TEAM PROJECT",
	"BUILD AND CREATE",
	"MOONSHOT PROJECT",
	"SOLVE PROBLEM",
	"CODE PROJECT",
	"BUILD THE FUTURE",
	"YOU WIN MOONSHOT",
	"HACK CLUB",
	"I SOLVE PROBLEM",
]




var message1 = "I love Moonshot"
var message2 = "Hello world"
var task = "Hello Moonshot"

var decrypting = false

var increase_amount = 0.4
var timer = 0
var time_left = 90
var last_points := -1
var last_lives := -1
var last_multiplier := -1.0
var bar_bonus_locked := false

func _ready() -> void:
	Gs.restart()
	bar_rect.scale.y = 0.4
	$Margin/Layout/StatusBar/Timer.text = str(time_left)
	call_deferred("_cache_pivots")
	new_task()
	update()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("submit"):
		checkAnswer()
		new_task()

func _process(delta: float) -> void:
	if bar_rect.scale.y >= 1:
		award_bar_full_bonus()
	if bar_rect.scale.y > 0.05:
		bar_rect.scale.y -= delta / 40
	if bar_rect.scale.y < 0.2:
		bar_bonus_locked = false
	timer += delta
	if timer >= 1:
		time_left -=1
		$Margin/Layout/StatusBar/Timer.text = str(time_left)
		timer = 0
	if time_left <= 0:
		Gs.end()

func crypt(sentence : String):
	var list = sentence.split(" ")
	var crypt = ""
	for i in list:
		if words.has(i.to_upper()):
			crypt += words[(i.to_upper())] + " "
		else:
			crypt += i + " "
	return (crypt.strip_edges())

func decrypt(crypt : String):
	var list = crypt.split(" ")
	var sentence = ""
	for i in list:
		for k in words:
			if words[k] == i.to_lower():
				sentence += k + " "
	return (sentence.strip_edges())

func update():
	var points_changed := last_points != -1 and Gs.points != last_points
	var lives_changed := last_lives != -1 and Gs.lives != last_lives
	var multiplier_changed := last_multiplier != -1.0 and not is_equal_approx(Gs.multiplier, last_multiplier)
	hp_label.text = "lives: "
	for i in range(Gs.lives):
		hp_label.text += "● "
	multiplier_label.text = "x" + str("%0.2f" % Gs.multiplier)
	points_label.text = "Points: " + str(Gs.points)
	english1_label.text = message1
	english2_label.text = message2
	gibberish1_label.text = crypt(message1)
	gibberish2_label.text = crypt(message2)
	if decrypting:
		task_label.add_theme_color_override("font_color", Color(0.32, 0.72, 0.93, 1.0))
		task_label.text = crypt(task)
	else:
		task_label.add_theme_color_override("font_color", Color.WHITE)
		task_label.text = task
	
	answer_field.clear()
	call_deferred("focus_up")
	if points_changed:
		animate_points_change()
	if lives_changed:
		animate_lives_change(Gs.lives < last_lives)
	if multiplier_changed:
		animate_multiplier_change()
	last_points = Gs.points
	last_lives = Gs.lives
	last_multiplier = Gs.multiplier

func focus_up():
	answer_field.grab_focus()

func checkAnswer():
	var answer = (answer_field.text).to_lower().strip_edges()
	answer_field.text = ""
	if decrypting:
		var correct_answer = task.to_lower().strip_edges()
		if correct_answer == answer:
			Gs.points += 10 * Gs.multiplier
			bar_rect.scale.y += increase_amount
		else:
			Gs.lose_hp(1)
			Gs.checkifend()
				
	else:
		var correct_answer = crypt(task).to_lower().strip_edges()
		if correct_answer == answer:
			Gs.points += 10 * Gs.multiplier
			bar_rect.scale.y += 0.3
		else:
			Gs.lose_hp(1)
			Gs.checkifend()


func new_task():
	decrypting = randi() % 2 > 0
	if decrypting:
		$Margin/Layout/Content/PuzzleSection/PuzzleVBox/DecodeTitle.text = "Decrypt this!"
	else:
		$Margin/Layout/Content/PuzzleSection/PuzzleVBox/DecodeTitle.text = "Crypt this!"
		
	answer_field.editable = false
	
	var attempts := 0
	var found := false
	while attempts < 10 and not found:
		sentences.shuffle()
		task_sentences.shuffle()
		message1 = sentences[0]
		message2 = sentences[1]
		var known_words: Array = message1.split(" ")
		known_words.append_array(message2.split(" "))
		for i in range(2, len(task_sentences)):
			var candidate_words: Array = task_sentences[i].split(" ")
			if candidate_words.all(func(word): return word in known_words):
				task = task_sentences[i]
				found = true
		attempts += 1
	if not found:
		print("something went wrong")
		task = message1
	answer_field.editable = true
	answer_field.grab_focus()
	update()


func _on_submit_pressed() -> void:
	checkAnswer()
	new_task()



func _on_restart_pressed() -> void:
	Gs.restart()
	update()

func award_bar_full_bonus():
	if bar_bonus_locked:
		return
	bar_bonus_locked = true
	Gs.multiplier += 1
	bar_rect.scale.y = 0.1
	multiplier_label.text = "x" + str("%0.2f" % Gs.multiplier)
	animate_multiplier_change()
	# Unlock after the bar falls back down so it can be earned again.
	time_left += 10
	if bar_rect.scale.y < 0.2:
		bar_bonus_locked = false

func _cache_pivots():
	var labels: Array = [
		points_label,
		hp_label,
		multiplier_label,
		task_label,
		english1_label,
		english2_label,
		gibberish1_label,
		gibberish2_label
	]
	for label in labels:
		label.pivot_offset = label.size / 2

func animate_points_change():
	var tween := create_tween()
	tween.tween_property(points_label, "scale", Vector2(1.14, 1.14), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(points_label, "modulate", Color(0.95, 1.0, 0.78, 1.0), 0.12)
	tween.tween_property(points_label, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(points_label, "modulate", Color.WHITE, 0.18)

func animate_lives_change(lost_life: bool):
	var highlight := Color(1.0, 0.55, 0.55, 1.0) if lost_life else Color(0.75, 1.0, 0.85, 1.0)
	var tween := create_tween()
	tween.tween_property(hp_label, "scale", Vector2(1.12, 1.12), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(hp_label, "modulate", highlight, 0.12)
	tween.tween_property(hp_label, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(hp_label, "modulate", Color.WHITE, 0.18)

func animate_multiplier_change():
	var tween := create_tween()
	tween.tween_property(multiplier_label, "scale", Vector2(1.1, 1.1), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(multiplier_label, "modulate", Color(0.68, 0.93, 1.0, 1.0), 0.16)
	tween.tween_property(multiplier_label, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(multiplier_label, "modulate", Color.WHITE, 0.16)
