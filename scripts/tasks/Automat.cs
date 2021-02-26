using Godot;
using System;

public class Automat : TaskWithGUI
{
	public override string GetResourceLocation(){
		return "res://gui/automat.tscn";
	}
	public int done = 3;
	public bool kawa;
	

	private void _on_Timer_timeout()
	{
		done = 1;
	}

}
