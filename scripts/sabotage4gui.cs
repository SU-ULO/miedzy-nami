using Godot;
using System;

public class sabotage4gui : Control
{

	private void RequestPressedDeltaGUISync(int delta){
		Node network = (Node)GetTree().GetRoot().GetNode("Start").Get("network");
		network.Call("request_gui_sync", "sabotage4", new Godot.Collections.Dictionary<string, object>(){
			["currentlyPressedDelta"] = delta
		});
	}
	
	private void OnSwitchDown()
	{
		RequestPressedDeltaGUISync(1);
		Label label = (Label) GetNode("ColorRect/Label");
		label.Text = "Oczekiwanie na drugiego gracza...";
		TextureButton button = (TextureButton) GetNode("ColorRect/switch1");
		button.Modulate = new Color("#483030");
	}
	
	private void OnSwitchUp()
	{
		RequestPressedDeltaGUISync(-1);
		Label label = (Label) GetNode("ColorRect/Label");
		label.Text= "Wciśnij znak zapytania!";
		TextureButton button = (TextureButton) GetNode("ColorRect/switch1");
		button.Modulate = new Color("#FFFFFF");
	}

}
