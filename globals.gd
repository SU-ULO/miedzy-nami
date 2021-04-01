extends Node

var start

func read_file(file: String):
	var f := File.new()
	if f.open(file, File.READ) != OK:
		return null
	var json = JSON.parse(f.get_as_text())
	if json.error==OK:
		return json.result
	return null

func save_file(file: String, v):
	if v is Array or v is Dictionary:
		var f := File.new()
		if f.open(file, File.WRITE)==OK:
			f.store_string(to_json(v))
