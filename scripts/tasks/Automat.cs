using Godot;
using System;

public class Automat : TaskWithGUI
{
	public override string GetResourceLocation(){
		return "res://gui/automat.tscn";
	}
	public override string ToString(){
		return "AULA: zrób sobie kawusię";
	}
	public int done = 3;
	public bool kawa;
	

	private void _on_Timer_timeout()
	{
		done = 1;
	}

}
