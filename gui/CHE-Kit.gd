extends Control

var inbox = Dictionary()

var kits = [["HCl", "szkielko"],["probowka","szmatka"],["NaOH", "zlewka"]] #has to be sorted
var kitsCount
var taskKit
var userKit = []

func _ready():
	randomize()
	kitsCount = kits.size()
	taskKit = kits[randi()%kitsCount]
	print(taskKit)

