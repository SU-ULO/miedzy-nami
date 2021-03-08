using Godot;
using System;

public class PHYSto : TaskWithGUI
{
	public override string GetResourceLocation(){
		return "res://gui/PHY-Sto.tscn";
	}
	public override string ToString(){
		return "SALA FIZYCZNA: zmierz pełen okres wahadła";
	}
}
