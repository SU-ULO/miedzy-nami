using Godot;
using System;

public class sabotage4gui : Control
{

    public static bool pressed = false;

    public static void RequestPressedDeltaGUISync(Node caller, int delta)
    {
        Node network = (Node)caller.GetTree().GetRoot().GetNode("Start").Get("network");
        network.Call(
            "request_gui_sync", "sabotage4", new Godot.Collections.Dictionary<string, object>()
            {
                ["currentlyPressedDelta"] = delta
            }
        );
    }
    
    private void OnSwitchDown()
    {
        if(pressed)
            return;
        pressed = true;
        RequestPressedDeltaGUISync(this, 1);
        Label label = (Label) GetNode("ColorRect/Label");
        label.Text = "Oczekiwanie na drugiego gracza...";
        TextureButton button = (TextureButton) GetNode("ColorRect/switch1");
        button.Modulate = new Color("#483030");
    }
    
    private void OnSwitchUp()
    {
        if(!pressed)
            return;
        pressed = false;
        RequestPressedDeltaGUISync(this, -1);
        Label label = (Label) GetNode("ColorRect/Label");
        label.Text= "Wciśnij znak zapytania!";
        TextureButton button = (TextureButton) GetNode("ColorRect/switch1");
        button.Modulate = new Color("#FFFFFF");
    }

}
