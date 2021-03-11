using Godot;
using System;

public class TaskExampleGUI : TaskWithGUI
{
	public override string GetResourceLocation(){
		return "res://gui/INF-Update.tscn";
	}
	public override string ToString()
	{
		return "SALA INFORMATYCZNA: zaktualizuj komputer";
	}
}
