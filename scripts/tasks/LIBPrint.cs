using Godot;
using System;

public class LIBPrint : TaskWithGUI
{
	public override string GetResourceLocation(){
		return "res://gui/MAT-Karta.tscn";
	}
	
	public override string ToString(){
		return "BIBLIOTEKA: wydrukuj dokument";
	}
}
