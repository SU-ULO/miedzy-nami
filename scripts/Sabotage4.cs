using Godot;
using System;

public class Sabotage4 : StaticBody2D
{
	public static int currentlyPressed = 0;
	public static int needed = 2;
	public static bool signalAttached = false;
	
	public override void _Ready(){
		AddToGroup("entities");
		AddToGroup("interactable");
		Node network = (Node)GetTree().GetRoot().GetNode("Start").Get("network");
		if(signalAttached == false)
		{
			signalAttached = true;
			network.Connect("gui_sync", this, "HandleGUISync");
		}
	}
	
	public void HandleGUISync(string guiName, Godot.Collections.Dictionary<String, object> data){
		Node network = (Node)GetTree().GetRoot().GetNode("Start").Get("network");
		if(guiName == GetName()){
			if(data.ContainsKey("currentlyPressedDelta"))
				currentlyPressed += (int)data["currentlyPressedDelta"];
			if(data.ContainsKey("currentlyPressed"))
				currentlyPressed = (int)data["currentlyPressed"];
		}
		
		if(currentlyPressed >= needed)
			network.Call("request_end_sabotage", 4);
			
		Godot.GD.Print("state: "+currentlyPressed);
	}

	public bool Interact(Node2D body){
		Node network = (Node)GetTree().GetRoot().GetNode("Start").Get("network");
		Node2D player = (Node2D)network.Get("own_player");
		
		if(((int)player.Get("currentSabotage")) != 4){
			Godot.GD.Print("currentSabotage: " + player.Get("currentSabotage"));
			return false;
		}
			
		Node canvasLayer = (Node)GetOwner().GetNode("CanvasLayer");
		Resource gui = ResourceLoader.Load("res://gui/sabotage4.tscn");
		Node guiInstance = ((PackedScene)gui).Instance();
		guiInstance.AddToGroup("gui_sabotage_4");
		canvasLayer.AddChild(guiInstance);
		
		
		return true;
	}
	
	public bool EndInteraction(Node2D b){
		Node n = (Node)GetOwner().GetNode("CanvasLayer");
		Godot.Collections.Array children = n.GetChildren();
		
		// Kill all children 
		foreach (Node child in children){
			if(child.IsInGroup("gui_sabotage_4"))
				n.RemoveChild(child);
			else
				GD.Print(child.GetName() + " is staying attached to " + "CanvasLayer");
		}
		
		return true;
	}

}
