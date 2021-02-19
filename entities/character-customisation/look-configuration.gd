class_name LookConfiguration

var skin = "1"
var mouth = "neutral closed"
var nose = "long nose"
var eye = "neutral_open"
var eye_color = "darkblue"


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
		return name + "/bonus/skin" + skin + name + ".png"
	else:
		return "przykromi"
		
func hasColoredEyes():
	return not eye in noColorEyes 

