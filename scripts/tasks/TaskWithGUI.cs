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
		Node parent = (Node)gui.GetParent();
		TaskWithGUIEnumerate(parent);
		
	}
	
	private static void TaskWithGUIEnumerate(Node c){
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
	
	public override void TaskInteract(Godot.Node2D body){

		// If this task is complete, do not open the window
		// We might want to change this behavior, but I've put it here as an indicator of the task
		// being complete, because we don't have a Task List GUI yet.
		if(this.state >= this.maxState)
			return;

		// Open the specifed GUI by the resource path
		// To change which GUI is being opened, create a class overriding GetResourceLocation
		Resource gui = ResourceLoader.Load(GetResourceLocation());
		Node guiInstance = ((PackedScene)gui).Instance();
		guiInstance.AddToGroup("gui_task_"+taskID);
		// task name here ???
		body.GetNode("GUI").Call("replace_on_canvas", guiInstance);
	}
	
	public override void TaskEndInteraction(Godot.Node2D body){
		GD.Print("koniec");
		body.GetNode("GUI").Call("clear_canvas");
	}
	
	public virtual bool Interact(Godot.Node2D body){
		GD.Print("Trying to open task "+ taskID+ " " + ToString() + " "+this.Local);
		if(this.Local)
			TaskInteract(body);
		
		return this.Local;
	}
	
	public virtual void EndInteraction(Godot.Node2D body){
		TaskEndInteraction(body);
	}

}
