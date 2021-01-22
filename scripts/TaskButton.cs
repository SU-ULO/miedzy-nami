using Godot;
using System;

public class TaskButton : Task, IInteractable
{
	public static bool ButtonClicked = false;
	
	public override void _Ready(){
		AddToGroup("tasks");
	}
	
	public override void TaskInteract(){
		// można zrobić lepiej, ale na razie może być
		Control n = (Control)GetTree().GetRoot().GetNode("/root/Main/CanvasLayer/gui");
		n.Visible = true;
	}
	
	public void Interact(){
		TaskInteract();
	}
}
