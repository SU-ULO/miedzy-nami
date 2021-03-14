using Godot;
using System;

public class BIOBug : TaskWithGUI
{
	public override string GetResourceLocation(){
		return "res://gui/BIO-Bug.tscn";
	}
	public override string ToString(){
		return "SALA BIOLOGICZNA: nakarm robaka";
	}
	public BIOBug(){
		this.category = TaskCategory.Easy;
	}
}
