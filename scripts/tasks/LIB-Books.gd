extends Node2D

var toDrag = []
var toSort = 9

var books = ["book-green1", "book-green2", "book-green3", "book-blue1", "book-blue2", "book-blue3", "book-red1", "book-red2", "book-red3"]

var dragged = null

func checkForEnd():
	if books.empty():
		$Timer.start()
		yield($Timer, "timeout")
		TaskWithGUI.TaskWithGUICompleteTask(self)
