using Godot;
using System;

public class sabotage4gui : Control
{

	private void RequestPressedDeltaGUISync(int delta){
		Node network = (Node)GetTree().GetRoot().GetNode("Start").Get("network");
		network.Call("request_gui_sync", GetName(), new Godot.Collections.Dictionary<string, object>(){
			["currentlyPressedDelta"] = delta
		});
	}
	
	private void OnSwitchDown()
	{
		RequestPressedDeltaGUISync(1);
	}
	
	private void OnSwitchUp()
	{
		RequestPressedDeltaGUISync(-1);
	}

}
