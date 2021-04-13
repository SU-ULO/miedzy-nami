extends Node


func _ready():
	get_settings()

func get_settings():
	var settings = get_parent().serversettings
	$ServerSettingsContainer/ServerHidden/ServerHiddenCheckBox.pressed=settings["hidden"]
	$ServerSettingsContainer/ServerName/ServerNameField.text=settings["name"]

func set_settings():
	var settings = get_parent().serversettings
	settings["hidden"]=$ServerSettingsContainer/ServerHidden/ServerHiddenCheckBox.pressed
	settings["name"]=$ServerSettingsContainer/ServerName/ServerNameField.text
	Globals.save_file("user://ss.settings", settings)


func _on_ServerAcceptButton_pressed():
	if get_owner().get_node("Create/ServerSettingsContainer/ServerName/ServerNameField").text == "":
		get_owner().get_node("Create/AnimationPlayer").play("highlight")
	else:
		set_settings()
		get_parent().request_start_server()
