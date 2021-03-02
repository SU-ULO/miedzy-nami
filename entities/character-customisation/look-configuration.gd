class_name LookConfiguration

var skin = "1"
var mouth = "neutral closed"
var nose = "long nose"
var eye = "neutral_open"
var eye_color = "darkblue"
var hair = "short hair"
var hairColor = 1
var hasBottom = 1
var topClothes = "shirt"

var hairPos = {"Velma long hair": 384, "Velma short hair":266, "afro":195, "bob cut":239, "curly afroish":225, "fade":248, "fade2":195, "kok":179, "koki":242, "long hair":379, "ponytail":192, "ponytails":230, "puffy hair":240, "short hair":240, "very short":283, "jheri curl":248, "short hair 2": 212, "wavy long hair":378, "wavy short hair":280, "bald":0}


var clothes
var hasSkinColorMouth = ["cheeks mouth closed", "cheeky smile semi-closed", "chewing smile closed", "miserable closed", "old smile", "sad closed", "smile closed", "smug smile closed", "wide smile closed"]
var hasBonusEyes = ["bored_open", "clumsy_open", "old_open", "sad_open", "smug_open", "suspicious_open", "suspicious_semi-open", "winking"]
var noColorEyes = ["bored_closed", "scared_closed", "happy_closed", "sad_closed"]
var hasSkinColorEyes = ["bored_closed", "scared_closed"]

func getMouthPath():
	if mouth in hasSkinColorMouth:
		return "res://textures/character/face parts/mouths/" + mouth + "/skin" + skin + " " + mouth + ".png"
	else:
		return "res://textures/character/face parts/mouths/" + mouth + ".png"

func getEyePath(frame=1):
	if eye in noColorEyes:
		if eye in hasSkinColorEyes:
			return "res://textures/character/face parts/oczy/frame" + str(frame) + "/" + eye + "/skin" + skin + "_" + eye + ".png"
		else:
			return "res://textures/character/face parts/oczy/frame" + str(frame) + "/" + eye + "/" + eye + ".png"
	else:
		return "res://textures/character/face parts/oczy/frame" + str(frame) + "/" + eye + "/" + eye_color + "_" + eye + ".png"

func getEyeBonusPath(frame=1):
	if eye in hasBonusEyes:
		return "res://textures/character/face parts/oczy/frame" + str(frame)+ "/" + eye + "/bonus/skin" + skin + "_" + eye + ".png"
	else:
		return "przykromi"
		
func hasColoredEyes():
	return not eye in noColorEyes 

func getHairPath():
	return ("res://textures/character/hair/" + hair + "/hair" + str(hairColor) + ".png")

func getHairPos():
	return hairPos[hair]

func getNosePath():
	return "res://textures/character/face parts/noses/" + nose + ".png"

func getSkinPath():
	return "res://textures/character/face_front/skin" + skin + ".png"

func getBodyPath(frame):
	#frame 4 means front
	return "res://textures/character/body/frame" + str(frame) + "/skin" + skin + ".png"

func getTopClotes(frame, color):
	#frame 4 means front
	return "res://textures/character/clothes/shirt/frame" + str(frame) + "/" + topClothes + str(color) + ".png"
