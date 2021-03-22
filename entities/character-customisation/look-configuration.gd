extends Node

class_name LookConfiguration

var skin := "1"
var mouth := "neutral closed"
var nose := "long nose"
var eye := "neutral_open"
var eye_color := "darkblue"
var hair := "afro"
var hairColor := 1
var hasBottom := 0
var topClothes := "dress"

const hairPos := {"Velma long hair": 384,
	"Velma short hair":266,
	"afro":195,
	"bob cut":239,
	"curly afroish":225,
	"fade":248,
	"fade2":195,
	"kok":179,
	"koki":242,
	"long hair":379,
	"ponytail":192,
	"ponytails":230,
	"puffy hair":240,
	"short hair":240,
	"very short":283,
	"jheri curl":248,
	"short hair 2": 212,
	"wavy long hair":378,
	"wavy short hair":280,
	"bald":0}


var clothes
const hasSkinColorMouth = ["cheeks mouth closed", "cheeky smile semi-closed", "chewing smile closed", "miserable closed", "old smile", "sad closed", "smile closed", "smug smile closed", "wide smile closed"]
const hasSkinColorMouthSide = ["cheeks mouth closed", "cheeky smile semi-closed", "chewing smile closed","Doraemon lips closed", "duck lips closed", "miserable closed", "old smile", "sad closed", "smile closed", "smug smile closed","UwU smile closed", "whistling lips semi-closed", "wide smile closed"]
const hasBonusEyes = ["bored_open", "clumsy_open", "old_open", "sad_open", "smug_open", "suspicious_open", "suspicious_semi-open", "winking"]
const noColorEyes = ["bored_closed", "scared_closed", "happy_closed", "sad_closed"]
const hasSkinColorEyes = ["bored_closed", "scared_closed"]

func getMouthPath(frame=1):
	if frame == 1:
		if mouth in hasSkinColorMouth:
			return "res://textures/character/face parts/mouths/frame" + str(frame) + "/" + mouth + "/skin" + skin + " " + mouth + ".png"
		else:
			return "res://textures/character/face parts/mouths/frame" + str(frame) + "/" + mouth + ".png"
	else:
		if mouth in hasSkinColorMouthSide:
			return "res://textures/character/face parts/mouths/frame" + str(frame) + "/" + mouth + "/skin" + skin + " " + mouth + ".png"
		else:
			return "res://textures/character/face parts/mouths/frame" + str(frame) + "/" + mouth + ".png"
	
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

func getHairPath(frame=1):
	return ("res://textures/character/hair/frame"+ str(frame) + "/" + hair + "/hair" + str(hairColor) + ".png")

func getHairPos():
	return hairPos[hair]

func getNosePath(frame=1):
	if frame == 1:
		return "res://textures/character/face parts/noses/frame" + str(frame) + "/" + nose + ".png"
	else:
		if nose != "nostril nose":
			return "res://textures/character/face parts/noses/frame" + str(frame) + "/" + nose +"/skin" + skin + ".png"
		else:
			return "res://textures/character/face parts/noses/frame2/nostril nose.png"
func getSkinPath():
	return "res://textures/character/face_front/skin" + skin + ".png"

func getBodyPath(frame):
	#frame 4 means front
	return "res://textures/character/body/frame" + str(frame) + "/skin" + skin + ".png"

func getTopClotes(frame, color):
	#frame 4 means front
	return "res://textures/character/clothes/"+ topClothes + "/frame" + str(frame) + "/" + topClothes + str(color) + ".png"

func get_look():
	var clothes_dict = {}
	clothes_dict["skin"] = skin
	clothes_dict["mouth"] = mouth
	clothes_dict["nose"] = nose
	clothes_dict["eye"] = eye
	clothes_dict["eye_color"] = eye_color
	clothes_dict["hair"] = hair
	clothes_dict["hairColor"] = hairColor
	clothes_dict["hasBottom"] = hasBottom
	clothes_dict["topClothes"] = topClothes
	return clothes_dict
	
func set_look(clothes_dict):
	skin = clothes_dict["skin"]
	mouth = clothes_dict["mouth"]
	nose = clothes_dict["nose"]
	eye = clothes_dict["eye"]
	eye_color = clothes_dict["eye_color"]
	hair = clothes_dict["hair"]
	hairColor = clothes_dict["hairColor"]
	hasBottom = clothes_dict["hasBottom"]
	topClothes = clothes_dict["topClothes"]
