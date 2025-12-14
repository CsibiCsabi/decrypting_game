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
@onready var game_over_overlay: ColorRect = %GameOverOverlay
@onready var bar_rect: ColorRect = %Bar

var sentences = [
	"this game is simple",
	"logic is the pattern",
	"the rule is clear",
	"player learn the rule",
	"player test the code",
	"risk is a cost",
	"reward is the goal",
	"the move is the next step",
	"smart player build the system",
	"the system is stable",
	"focus make the mind ready",
	"the code is complex"
]
var words = {
	"is": "IS",
	"the": "THE",
	"a": "A",
	"this": "THS",
	"that": "THT",
	"it": "IT",
	"game": "GAM",
	"simple": "SMP",
	"logic": "LGC",
	"pattern": "PTN",
	"rule": "RUL",
	"clear": "CLR",
	"player": "PLR",
	"learn": "LRN",
	"test": "TST",
	"code": "COD",
	"risk": "RSK",
	"cost": "CST",
	"reward": "RWD",
	"goal": "GOL",
	"move": "MOV",
	"next": "NXT",
	"step": "STP",
	"smart": "SMT",
	"build": "BLD",
	"system": "SYS",
	"stable": "STB",
	"focus": "FCS",
	"make": "MK",
	"mind": "MND",
	"ready": "RDY",
	"complex": "CPX"
}

var message1 = "I love moonshot"
var message2 = "Hello world"
var task = "Hello Moonshot"

var decrypting = false

var increase_amount = 0.4
var timer = 0
var time_left = 60

func _ready() -> void:
	game_over_overlay.visible = false
	bar_rect.scale.y = 0.4
	new_task()
	update()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("submit"):
		checkAnswer()
		new_task()

func _process(delta: float) -> void:
	if bar_rect.scale.y > 0.05:
		bar_rect.scale.y -= delta / 40
	timer += delta
	if timer >= 1:
		time_left -=1
		$Margin/Layout/StatusBar/Timer.text = str(time_left)
		timer = 0
	

func crypt(sentence : String):
	var list = sentence.split(" ")
	var crypt = ""
	for i in list:
		if words.has(i.to_lower()):
			crypt += words[(i.to_lower())] + " "
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
	hp_label.text = "lives: "
	for i in range(Gs.lives):
		hp_label.text += "● "
	multiplier_label.text = "x" + str(Gs.multiplier)
	points_label.text = "Points: " + str(Gs.points)
	english1_label.text = message1
	english2_label.text = message2
	gibberish1_label.text = crypt(message1)
	gibberish2_label.text = crypt(message2)
	if decrypting:
		task_label.text = crypt(task)
	else:
		task_label.text = task
	
	answer_field.clear()
	call_deferred("focus_up")
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
			if Gs.lives <= 0:
				game_over_overlay.visible = true
	else:
		var correct_answer = crypt(task).to_lower().strip_edges()
		if correct_answer == answer:
			Gs.points += 10 * Gs.multiplier
			bar_rect.scale.y += 0.3
		else:
			Gs.lose_hp(1)
			if Gs.lives <= 0:
				game_over_overlay.visible = true

func new_task():
	answer_field.editable = false
	
	var attempts := 0
	var found := false
	while attempts < 10 and not found:
		sentences.shuffle()
		message1 = sentences[0]
		message2 = sentences[1]
		var known_words: Array = message1.split(" ")
		known_words.append_array(message2.split(" "))
		for i in range(2, len(sentences)):
			var candidate_words: Array = sentences[i].split(" ")
			if candidate_words.all(func(word): return word in known_words):
				task = sentences[i]
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
	game_over_overlay.visible = false
	Gs.restart()
	update()
