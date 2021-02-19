class_name LookConfiguration

var skin = "1"
var mouth = "neutral closed"
var nose = "long nose"

var hasSkinColorMouth = ["cheeks mouth closed", "cheeky smile semi-closed", "chewing smile closed", "miserable closed", "old smile", "sad closed", "smile closed", "smug smile closed", "wide smile closed"]

func getMouthPath(name):
	if name in hasSkinColorMouth:
		return name + "/skin" + skin + " " + name + ".png"
	else:
		return name + ".png"



