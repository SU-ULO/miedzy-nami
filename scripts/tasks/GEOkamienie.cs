using Godot;
using System;

public class GEOkamienie : TaskWithGUI
{
	public override string GetResourceLocation(){
		return "res://gui/GEO-kamienie.tscn";
	}
	
	public override string ToString(){
		return "SALA GEOGRAFICZNA: uporządkuj kamienie";
	}
	public GEOkamienie()
	{
		started = false;
	}
}
