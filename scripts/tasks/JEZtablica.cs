using Godot;
using System;

public class JEZtablica : TaskWithGUI
{
	public override string GetResourceLocation(){
		return "res://gui/tablica.tscn";
	}
	public override string ToString(){
		return "SALA JĘZYKOWA: wyczyść tablicę (1/2)";
	}
	public override int GetNextTaskID()
	{
		return GetTaskByTypeName("MATtablica").taskID;
	}
	public JEZtablica(){
		this.category = TaskCategory.VeryHard;
	}
}
