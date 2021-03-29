extends Control

signal exit()
signal leave_game()


func _on_TextureButton_pressed():
	emit_signal("exit")


func _on_TextureButton2_pressed():
	emit_signal("leave_game")
