using Godot;
using System;

public class JEZzwierzaki : TaskWithGUI
{
	public override string GetResourceLocation(){
		return "res://gui/JEZ-zwierzaki.tscn";
	}
	public override string ToString()
	{
		return "SALA JĘZYKOWA: naucz się nowych słówek";
	}
}
