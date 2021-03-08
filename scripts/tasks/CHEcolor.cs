using Godot;
using System;

public class CHEcolor : TaskWithGUI
{
	public override string GetResourceLocation(){
		return "res://gui/CHE-Color.tscn";
	}
	public override string ToString(){
		return "SALA CHEMICZNA: zmieszaj kolory";
	}
}
