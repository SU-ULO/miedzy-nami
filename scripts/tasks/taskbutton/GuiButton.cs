using Godot;
using System;

public class GuiButton : Button
{
	private void OnButtonClicked(){
		Task[] tasks = Task.GetTasksOfType(typeof(TaskWithGUI));
		GD.Print("We have "+tasks.Length+" tasks");
		foreach(Task task in tasks){
			GD.Print("Setting task state from OnButtonClicked");
			task.state = task.maxState;
		}
	}
}
