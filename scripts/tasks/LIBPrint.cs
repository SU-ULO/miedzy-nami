using Godot;
using System;

public class LIBPrint : TaskWithGUI
{
	public override string GetResourceLocation(){
		return "res://gui/drukowanko.tscn";
	}
	
	public override string ToString(){
		return "BIBLIOTEKA: wydrukuj dokument";
	}
	public LIBPrint(){
		this.category = TaskCategory.Easy;
	}
}
