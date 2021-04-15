using Godot;
using System;

public class Sabotage4TriggerLogic : Node
{
	public static int currentlyPressed = 0;
	public static int needed = 2;

	public override void _Ready()
	{
		Node network = (Node)GetTree().GetRoot().GetNode("Start").Get("network");
		network.Connect("gui_sync", this, "HandleGUISync");
		network.Connect("sabotage", this, "Cleanup");
	}
	
	public void Cleanup(int type){
		if(type == 4)
			currentylPressed = 0;
	}

	public void HandleGUISync(string guiName, Godot.Collections.Dictionary<String, object> data){
		Node network = (Node)GetTree().GetRoot().GetNode("Start").Get("network");
		if(guiName == "sabotage4"){
			Godot.GD.Print(data.Keys.Count, data.Count);
			foreach (String s in data.Keys){
				Godot.GD.Print("key: " + s);
			}
			
			if(data.ContainsKey("currentlyPressedDelta")){
				currentlyPressed += (int)data["currentlyPressedDelta"];
				Godot.GD.Print("Delta: " + (int)data["currentlyPressedDelta"]);
			}
			if(data.ContainsKey("currentlyPressed")){
				currentlyPressed = (int)data["currentlyPressed"];
				Godot.GD.Print("Setting total to " + currentlyPressed);
			}
			if(currentlyPressed >= needed){
				network.Call("request_end_sabotage", 4);
				Godot.GD.Print("state: "+currentlyPressed);
			}
		}
	}
}
