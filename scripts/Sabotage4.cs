using Godot;
using System;

public class Sabotage4 : Node2D, IInteractable
{
	public static int currentlyPressed = 0;
	public static int needed = 2;
	public static bool signalAttached = false;
	
	public override void _Ready(){
		AddToGroup("entities");
		AddToGroup("sabotage");
		Node network = (Node)GetTree().GetRoot().GetNode("Start").Get("network");
		network.Connect("sabotage", this, "SetInteractable");
		network.Connect("sabotage_end", this, "SetInteractable");
		if(signalAttached == false)
		{
			signalAttached = true;
			network.Connect("gui_sync", this, "HandleGUISync");
		}
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

	public bool Interact(Node2D body){
		Node network = (Node)GetTree().GetRoot().GetNode("Start").Get("network");
		Node2D player = (Node2D)network.Get("own_player");
		
		if(((int)player.Get("currentSabotage")) != 4){
			Godot.GD.Print("currentSabotage: " + player.Get("currentSabotage"));
			return false;
		}
			
		Resource gui = ResourceLoader.Load("res://gui/sabotage4.tscn");
		Node guiInstance = ((PackedScene)gui).Instance();
		guiInstance.AddToGroup("gui_sabotage_4");
		body.GetNode("GUI").Call("add_to_canvas", guiInstance);
		
		
		return true;
	}
	
	public void EndInteraction(Node2D body){
		body.GetNode("GUI").Call("clear_canvas");
	}
	
	public bool IsDone(){
		throw new Exception("Unimplemented, why is it called on this object?");
	}
	public void SetInteractable(int type)
	{
		if (type == 4)
		{
			AddToGroup("interactable");
		}else{
			if (IsInGroup("interactable")){
			RemoveFromGroup("interactable");
			}
		}
	}
}
