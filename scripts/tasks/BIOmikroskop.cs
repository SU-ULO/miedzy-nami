using Godot;
using System;

public class BIOmikroskop : TaskWithGUI
{
	public override string GetResourceLocation(){
		return "res://gui/BIO-mikroskop.tscn";
	}
	public override string ToString(){
		return "SALA BIOLOGICZNA: ustaw mikroskop";
	}
}
