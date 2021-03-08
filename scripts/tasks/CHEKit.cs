using Godot;
using System;

public class CHEKit : TaskWithGUI
{
	public override string GetResourceLocation(){
		return "res://gui/CHE-Kit.tscn";
	}
	public override string ToString(){
		return "SALA CHEMICZNA: przygotuj zestaw";
	}
}
