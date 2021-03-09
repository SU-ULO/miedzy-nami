using Godot;
using System;

public class HasloGEO : TaskWithGUI
{
	public override string GetResourceLocation(){
		return "res://gui/haslo.tscn";
	}
	public override string ToString(){
		return "SALA GEOGRAFICZNA: odblokuj komputer";
	}
	public HasloGEO()
	{
		started = false;
	}
}
