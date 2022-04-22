extends Node

class_name LookConfiguration

var skin := "skin1"
var mouth := "neutral closed"
var nose := "long nose"
var eye := "neutral_open"
var eye_color := "darkblue"
var hair := "afro"
var hairColor := "1"
var hasBottom := false
var topClothes := "dress"
var acc := "acc0" # nothing
var beard := "bald"
var beard_color := "black"

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
const hasNoJeans = ["dress", "hoodie", "sweater"]

# you can get that
# by running script/tools/look_randomizer.gd
var allloks = {"acc":["acc14", "acc15", "acc34", "acc26", "acc5", "acc32", "acc10", "acc22", "acc12", "acc3", "acc9", "acc25", "acc21", "acc31", "acc23", "acc8", "acc13", "acc4", "acc16", "acc28", "acc24", "acc27", "acc6", "acc2", "acc1", "acc11", "acc30", "acc29", "acc7", "acc18", "acc20", "acc33", "acc17", "acc19", "acc0"], "beard":["beard_medium", "fancy_stache", "scruffy_beard", "beard_short", "chin_curtain", "sideburns", "puberty_stache", "beard_long", "goatee", "scruffy_stache", "scruffy_goatee", "pencil_stache", "thin_stache", "scruffy_beard_long", "scruffy_chin", "bald"], "beard-color":["black", "dark_brown", "light_brown", "light_blonde", "dark_blonde", "red-orange", "green", "blue", "pink", "white", "red"], "clothes":["shirt", "tshirt", "dress", "hoodie", "sweater"], "eye":["angry_open", "beady_open", "beta_open", "bored_closed", "bored_open", "clumsy_open", "curious_open", "evil_open", "furious_open", "happy_closed", "happy_open", "narrowed_open", "neutral_open", "old_open", "pleading_open", "sad_closed", "sad_open", "scared_closed", "scared_open", "serious_open", "shocked_open", "smug_open", "staring_open", "suspicious_open", "suspicious_semi-open", "tired_open", "winking", "worried_open"], "eye-color":["lightblue", "darkblue", "lightgreen", "darkgreen", "lightbrown", "darkbrown"], "hair":["Velma long hair", "Velma short hair", "afro", "bob cut", "curly afroish", "fade", "fade2", "jheri curl", "kok", "koki", "long hair", "ponytail", "ponytails", "puffy hair", "short hair", "short hair 2", "very short", "wavy long hair", "wavy short hair", "bald"], "hair-color":["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"], "mouth":["cheeks mouth closed", "cheeky smile semi-closed", "chewing smile closed", "miserable closed", "old smile", "sad closed", "smile closed", "smile teeth", "smug smile closed", "smug smile teeth", "wide smile closed", "curious open", "disgusted teeth", "Doraemon lips closed", "duck lips closed", "neutral closed", "sad teeth", "scared teeth", "smile open", "sticking tongue closed", "UwU smile closed", "whistling lips semi-closed", "wide smile teeth"], "nose":["long nose", "long plump nose", "long thin nose", "neutral nose", "nostril nose", "small plump nose", "square nose", "triangular long nose", "triangular long plump nose", "triangular plump nose", "triangular short nose", "wide nose", "wide nostril nose", "wide plump nose", "wide round plump nose"], "skin":["skin1", "skin2", "skin3", "skin4", "skin5", "skin6", "skin7", "skin8", "skin9", "skin10", "skin11", "skin12"]}

func getMouthPath(frame=1):
	if frame == 1:
		if mouth in hasSkinColorMouth:
			return "res://textures/character/face parts/mouths/frame" + str(frame) + "/" + mouth + "/" + skin + " " + mouth + ".png"
		else:
			return "res://textures/character/face parts/mouths/frame" + str(frame) + "/" + mouth + ".png"
	else:
		if mouth in hasSkinColorMouthSide:
			return "res://textures/character/face parts/mouths/frame" + str(frame) + "/" + mouth + "/" + skin + " " + mouth + ".png"
		else:
			return "res://textures/character/face parts/mouths/frame" + str(frame) + "/" + mouth + ".png"
	
func getEyePath(frame=1):
	if eye in noColorEyes:
		if eye in hasSkinColorEyes:
			return "res://textures/character/face parts/oczy/frame" + str(frame) + "/" + eye + "/" + skin + "_" + eye + ".png"
		else:
			return "res://textures/character/face parts/oczy/frame" + str(frame) + "/" + eye + "/" + eye + ".png"
	else:
		return "res://textures/character/face parts/oczy/frame" + str(frame) + "/" + eye + "/" + eye_color + "_" + eye + ".png"

func getEyeBonusPath(frame=1):
	if eye in hasBonusEyes:
		return "res://textures/character/face parts/oczy/frame" + str(frame)+ "/" + eye + "/bonus/" + skin + "_" + eye + ".png"
	else:
		return "przykromi"
		
func hasColoredEyes():
	return not eye in noColorEyes 

func getHairPath(frame=1):
	return ("res://textures/character/hair/frame"+ str(frame) + "/" + hair + "/hair" + str(hairColor) + ".png")

func getBeardPath(frame=1):
	if beard == "bald":
		return ("res://textures/character/hair/frame"+ str(frame) + "/bald/hair1.png")
	return ("res://textures/character/beards/frame"+ str(frame) + "/" + beard + "/" + beard + "_" + beard_color + ".png")

func getHairPos():
	return hairPos[hair]

func getNosePath(frame=1):
	if frame == 1:
		return "res://textures/character/face parts/noses/frame" + str(frame) + "/" + nose + ".png"
	else:
		if nose != "nostril nose":
			return "res://textures/character/face parts/noses/frame" + str(frame) + "/" + nose +"/" + skin + ".png"
		else:
			return "res://textures/character/face parts/noses/frame2/nostril nose.png"
func getSkinPath():
	return "res://textures/character/face_front/" + skin + ".png"

func getBodyPath(frame):
	#frame 4 means front
	return "res://textures/character/body/frame" + str(frame) + "/" + skin + ".png"

func getTopClotes(frame, color):
	#frame 4 means front
	return "res://textures/character/clothes/"+ topClothes + "/frame" + str(frame) + "/" + topClothes + str(color) + ".png"

func getAccPath(frame=1):
	return "res://textures/character/accessories/frame" + str(frame) + "/" + acc + ".png"


func get_look():
	var clothes_dict = {}
	clothes_dict["skin"] = skin
	clothes_dict["mouth"] = mouth
	clothes_dict["nose"] = nose
	clothes_dict["eye"] = eye
	clothes_dict["eye-color"] = eye_color
	clothes_dict["hair"] = hair
	clothes_dict["hair-color"] = hairColor
	clothes_dict["hasBottom"] = hasBottom
	clothes_dict["clothes"] = topClothes
	clothes_dict["acc"] = acc
	clothes_dict["beard"] = beard
	clothes_dict["beard-color"] = beard_color	
	return clothes_dict
	
func set_look(clothes_dict):
	skin = clothes_dict["skin"]
	mouth = clothes_dict["mouth"]
	nose = clothes_dict["nose"]
	eye = clothes_dict["eye"]
	eye_color = clothes_dict["eye-color"]
	hair = clothes_dict["hair"]
	hairColor = clothes_dict["hair-color"]
	hasBottom = clothes_dict["hasBottom"]
	topClothes = clothes_dict["clothes"]
	acc = clothes_dict["acc"]
	beard = clothes_dict["beard"]
	beard_color = clothes_dict["beard-color"]
	
	
func get_random():
	var r = get_look()
	for i in allloks.keys():
		allloks[i].shuffle()
		r[i] = allloks[i][0]
	r["hasBottom"] = !hasNoJeans.has(r["clothes"])
	randomize()
	if randi() % 2 == 1:
		r["beard"] = "bald"
	return r
