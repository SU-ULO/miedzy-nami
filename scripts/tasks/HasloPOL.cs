using Godot;
using System;

public class HasloPOL : TaskWithGUI
{
	public override string GetResourceLocation(){
		return "res://gui/haslo.tscn";
	}
	public override string ToString(){
		return "SALA POLONISTYCZNA: odblokuj komputer";
	}
	public override int GetNextTaskID()
	{
		return GetTaskByTypeName("HasloGEO").taskID;
	}
	public HasloPOL()
	{
		started = false;
	}
}
