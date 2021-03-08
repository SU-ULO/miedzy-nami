using Godot;
using System;

public class TaskWithGUI : Task, IInteractable
{
	
	public virtual string GetResourceLocation(){
		return "res://gui/gui.tscn";
	}
	
	public TaskWithGUI(){
		maxState = 1;
	}
	
	public override void _Ready(){
		AddToGroup("interactable");
		AddToGroup("entities");
		AddToGroup("tasks");
	}
	
	public static void TaskWithGUICompleteTask(Control gui){
		TaskWithGUIEnumerate(gui);
		// try enumerating the parent groups too
		Control parent = (Control)gui.GetParent();
		TaskWithGUIEnumerate(parent);
		
	}
	
	private static void TaskWithGUIEnumerate(Control c){
		if(c == null)
			return;
		// Finish all tasks with the appropriate ID
		foreach(string gr in c.GetGroups()){
			if(gr.StartsWith("gui_task_"))
			{
				string taskIDString = gr.Substring("gui_task_".Length);
				int taskID;
				Int32.TryParse(taskIDString, out taskID);
				foreach(Task task in Task.tasks){
					if(task.taskID == taskID)
					{
						task.state = task.maxState;
					}
				}
			}
		}
	}
	
	public static Task GetTaskFromControl(Control c)
	{
		if(c == null)
			return null;
			
		foreach(string gr in c.GetGroups())
		{
			if(gr.StartsWith("gui_task_"))
			{
				string taskIDString = gr.Substring("gui_task_".Length);
				int taskID;
				Int32.TryParse(taskIDString, out taskID);
				foreach(Task task in Task.tasks)
				{
					if(task.taskID == taskID)
					{
						return task;
					}
				}
			}
		}
		
		return null;
	}
	
	public override void TaskInteract(){

		// If this task is complete, do not open the window
		// We might want to change this behavior, but I've put it here as an indicator of the task
		// being complete, because we don't have a Task List GUI yet.
		if(this.state >= this.maxState)
			return;

		// Open the specifed GUI by the resource path
		// To change which GUI is being opened, create a class overriding GetResourceLocation
		Node n = (Node)GetOwner().GetNode("CanvasLayer");
		Resource gui = ResourceLoader.Load(GetResourceLocation());
		Node guiInstance = ((PackedScene)gui).Instance();
		guiInstance.AddToGroup("gui_task_"+taskID);
		n.AddChild(guiInstance);
		
	}
	
	public override void TaskEndInteraction(){
		// Kill the GUI
		Node n = (Node)GetOwner().GetNode("CanvasLayer");
		Godot.Collections.Array children = n.GetChildren();
		
		// Kill all children 
		foreach (Node child in children){
			if(child.IsInGroup("gui_task_"+taskID))
				n.RemoveChild(child);
			else
				GD.Print(child.GetName() + " is staying attached to " + "CanvasLayer");
		}
	}
	
	public virtual bool Interact(){
		if(this.Local)
			TaskInteract();
		
		return this.Local;
	}
	
	public virtual void EndInteraction(){
		TaskEndInteraction();
	}

}
