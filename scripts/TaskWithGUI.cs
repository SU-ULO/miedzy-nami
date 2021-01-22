using Godot;
using System;

public class TaskWithGUI : Task, IInteractable
{
	
	public virtual string GetResourceLocation(){
		return "res://gui/gui.tscn";
	}
	
	public override void _Ready(){
		maxState = 1;
		AddToGroup("interactable");
		AddToGroup("entities");
	}
	
	public override void TaskInteract(){

		// If this task is complete, do not open the window
		// We might want to change this behavior, but I've put it here as an indicator of the task
		// being complete, because we don't have a Task List GUI yet.
		if(this.state >= this.maxState)
			return;

		// Open the specifed GUI by the resource path
		// To change which GUI is being opened, create a class overloading GetResourceLocation
		Node n = (Node)GetTree().GetRoot().GetNode("/root/Main/CanvasLayer");
		Resource gui = ResourceLoader.Load(GetResourceLocation());
		Node guiInstance = ((PackedScene)gui).Instance();
		guiInstance.AddToGroup("gui_task_"+taskID);
		n.AddChild(guiInstance);
		
	}
	
	public override void TaskEnd(){
		
		GD.Print("TaskEnd extended");
		// Kill the GUI
		Node n = (Node)GetTree().GetRoot().GetNode("/root/Main/CanvasLayer");
		Godot.Collections.Array children = n.GetChildren();
		
		// Kill all children 
		foreach (Node child in children){
			if(child.IsInGroup("gui_task_"+taskID))
				n.RemoveChild(child);
			else
				GD.Print(child.GetName() + " is staying attached to " + "/root/Main/CanvasLayer");
		}
	}
	
	public void Interact(){
		TaskInteract();
	}
}
