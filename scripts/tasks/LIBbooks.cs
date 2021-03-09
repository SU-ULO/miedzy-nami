using Godot;
using System;

public class LIBbooks : TaskWithGUI
{
	public override string GetResourceLocation(){
		return "res://gui/LIB-books.tscn";
	}
	public override string ToString(){
		return "BIBLIOTEKA: wypożycz książkę";
	}
	public override int GetNextTaskID()
	{
		return GetTaskByTypeName("GEOkamienie").taskID;
	}
}
