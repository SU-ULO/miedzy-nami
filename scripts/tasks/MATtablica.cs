using Godot;
using System;

public class MATtablica : TaskWithGUI
{
	public override string GetResourceLocation(){
		return "res://gui/tablica.tscn";
	}
	public override string ToString(){
		return "SALA MATEMATYCZNA: wyczyść tablicę (2/2)";
	}
	public MATtablica(){
		this.category = TaskCategory.VeryHard;
		started = false;
	}
}
