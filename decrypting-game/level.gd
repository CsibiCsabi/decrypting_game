extends Control

func _ready() -> void:
	
	update()


var sentences = [
	"I love Moonshot",
	"Moonshot forever",
	"Hello moonshot",
	"I love world"
]
var words = {
	"i" : "gn",
	"love" : "mi",
	"moonshot" : "yox",
	"hello" : "forq",
	"world" : "miar",
	"forever" : "dalli"
}

var message1 = "I love moonshot"
var message2 = "Hello world"
var task = "Hello Moonshot"

func crypt(sentence : String):
	var list = sentence.split(" ")
	print(list)
	var crypt = ""
	for i in list:
		crypt += words[i.to_lower()] + " "
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
	$Hp.text = str(Gs.lives)
	$Multiplier.text = str(Gs.multiplier)
	$English1.text = message1
	$English2.text = message2
	$Gibberish1.text = crypt(message1)
	$Gibberish2.text = crypt(message2)
	$Gibberish2.text = crypt(message2)
	$Task.text = crypt(task)
	$Points.text = "Points: " + str(Gs.points)

func checkAnswer():
	var correct_answer = task.to_lower().strip_edges()
	var answer = ($TextEdit.text).to_lower().strip_edges()
	if correct_answer == answer:
		Gs.points += 10 * Gs.multiplier
		new_task()
	else:
		Gs.lose_hp(1)
		if Gs.lives <= 0:
			$ColorRect.visible = true

func new_task():
	message1 = sentences.pick_random()
	message2 = sentences.pick_random()
	task = sentences.pick_random()
	update()
	

func _on_submit_pressed() -> void:
	checkAnswer()
	update()



func _on_restart_pressed() -> void:
	$ColorRect.visible = false
	Gs.restart()
	update()
