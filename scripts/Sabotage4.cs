using Godot;
using System;

public class Sabotage4 : Node2D, IInteractable
{
    
    public override void _Ready()
    {
        AddToGroup("entities");
        AddToGroup("sabotage");
        Node network = (Node)GetTree().GetRoot().GetNode("Start").Get("network");
        network.Connect("sabotage", this, "SetInteractable");
        network.Connect("sabotage_end", this, "SetInteractable");
    }

    public bool Interact(Node2D body)
    {
        Node network = (Node)GetTree().GetRoot().GetNode("Start").Get("network");
        Node2D player = (Node2D)network.Get("own_player");
        
        if(((int)player.Get("currentSabotage")) != 4)
        {
            Godot.GD.Print("currentSabotage: " + player.Get("currentSabotage"));
            return false;
        }
            
        Resource gui = ResourceLoader.Load("res://gui/sabotage4.tscn");
        Node guiInstance = ((PackedScene)gui).Instance();
        guiInstance.AddToGroup("gui_sabotage_4");
        body.GetNode("GUI").Call("add_to_canvas", guiInstance);
        
        return true;
    }
    
    public void EndInteraction(Node2D body)
    {
        if(sabotage4gui.pressed)
        {
            sabotage4gui.RequestPressedDeltaGUISync(this, -1);
            sabotage4gui.pressed = false;
        }
        body.GetNode("GUI").Call("clear_canvas");
    }
    
    public bool IsDone()
    {
        throw new Exception("Unimplemented, why is it called on this object?");
    }
    
    public void SetInteractable(int type)
    {
        if (type == 4)
        {
            AddToGroup("interactable");
        }
        else
        {
            if (IsInGroup("interactable"))
            {
                RemoveFromGroup("interactable");
            }
        }
    }
}
