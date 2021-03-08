using Godot;
using System;

public class MATKarta : TaskWithGUI
{
	public override string GetResourceLocation(){
		return "res://gui/MAT-Karta.tscn";
	}
	
	public override string ToString(){
		return "SALA MATEMATYCZNA: rozdaj karty pracy";
	}
}
