class_name LookConfiguration

var skin = "1"
var mouth = "neutral closed"
var nose = "long nose"
var eye = "neutral_open"
var eye_color = "darkblue"
var hair = "short hair"
var hairColor = 1
var hairPos = {"Velma long hair": 384, "Velma short hair":266, "afro":195, "bob cut":239, "curly afroish":225, "fade":248, "fade2":195, "kok":179, "koki":242, "long hair":379, "ponytail":192, "ponytails":230, "puffy hair":240, "short hair":240, "very short":283, "jheri curl":248, "short hair 2": 212, "wavy long hair":378, "wavy short hair":280, "bald":0}

var hasSkinColorMouth = ["cheeks mouth closed", "cheeky smile semi-closed", "chewing smile closed", "miserable closed", "old smile", "sad closed", "smile closed", "smug smile closed", "wide smile closed"]
var hasBonusEyes = ["bored_open", "clumsy_open", "old_open", "sad_open", "smug_open", "suspicious_open", "suspicious_semi-open", "winking"]
var noColorEyes = ["bored_closed", "scared_closed", "happy_closed", "sad_closed"]
var hasSkinColorEyes = ["bored_closed", "scared_closed"]

func getMouthPath(name):
	if name in hasSkinColorMouth:
		return name + "/skin" + skin + " " + name + ".png"
	else:
		return name + ".png"

func getEyePath(name):
	if name in noColorEyes:
		if name in hasSkinColorEyes:
			return name + "/skin" + skin + "_" + name + ".png"
		else:
			return name + "/" + name + ".png"
	else:
		return name + "/" + eye_color + "_" + name + ".png"

func getEyeBonusPath(name):
	if name in hasBonusEyes:
		return name + "/bonus/skin" + skin + "_" + name + ".png"
	else:
		return "przykromi"
		
func hasColoredEyes():
	return not eye in noColorEyes 

func getHairPath():
	return ("res://textures/character/hair/" + hair + "/hair" + str(hairColor) + ".png")

func getHairPos():
	return hairPos[hair]
