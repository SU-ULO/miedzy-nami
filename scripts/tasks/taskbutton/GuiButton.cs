using Godot;
using System;

public class GuiButton : Button
{
	private void OnButtonClicked(){
		TaskWithGUI.TaskWithGUICompleteTask(this);
	}
}
