using Godot;
using System;

public class Haslo : TaskWithGUI
{
	public override string GetResourceLocation(){
		return "res://gui/haslo.tscn";
	}
	public override string ToString(){
		return "odblokuj komputer";
	}
}
