using Godot;
using System;

public class HasloINF : TaskWithGUI
{
	public override string GetResourceLocation(){
		return "res://gui/haslo.tscn";
	}
	public override string ToString(){
		return "SALA INFORMATYCZNA: odblokuj komputer (1/3)";
	}
	public HasloINF(){
		this.category = TaskCategory.VeryHard;
	}
	public override int GetNextTaskID()
	{
		return GetTaskByTypeName("HasloPOL").taskID;
	}
}
