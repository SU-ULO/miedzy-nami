using Godot;
using System;

public class GuiButton : Button
{
	private void OnButtonClicked(){

		Control parent = (Control)GetParent();
		foreach(string gr in parent.GetGroups()){
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
}
