extends Control




var sentences = [
	"a b c",
	"b c d",
	"c d e",
	"d e a",
	"e a b",
	"a b",
	"a c",
	"a d",
	"c d",
	"b e",
	"d e"
]
var words = {
	"a" : "a",
	"b" : "b",
	"c" : "c",
	"d" : "d",
	"e" : "e"
}

var message1 = "I love moonshot"
var message2 = "Hello world"
var task = "Hello Moonshot"
func _ready() -> void:
	new_task()
	update()

func _process(delta: float) -> void:
	if $Bar.scale.y > 0.05:
		$Bar.scale.y -= delta / 10
		


func crypt(sentence : String):
	var list = sentence.split(" ")
	print(list)
	var crypt = ""
	for i in list:
		crypt += words[(i.to_lower())] + " "
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
		$Bar.scale.y += 0.3
	else:
		Gs.lose_hp(1)
		if Gs.lives <= 0:
			$ColorRect.visible = true
	$TextEdit.text = ""

func new_task():
	sentences.shuffle()
	
	message1 = sentences[0]
	message2 = sentences[1]
	var known_words = message1.split(" ")
	known_words.append_array(message2.split(" "))
	var taskFound = false
	var i = 2
	while i < len(sentences) and not taskFound:
		var good = true
		for word in sentences[i].split(" "):
			if word not in known_words:
				good = false
		if good:
			print("good task")
			taskFound = true
			task = sentences[i]
			update()
		i+=1
	if not taskFound:
		print("somethin went wrong!!")
		update()


func _on_submit_pressed() -> void:
	checkAnswer()
	new_task()



func _on_restart_pressed() -> void:
	$ColorRect.visible = false
	Gs.restart()
	update()
