using Godot;
using System;

public class AULAPianino : TaskWithGUI
{
	public override string GetResourceLocation(){
		return "res://gui/AULA-pianino.tscn";
	}
	public override string ToString()
	{
		return "AULA: zagraj na pianinie";
	}
	public AULAPianino(){
		this.category = TaskCategory.Easy;
	}
}
