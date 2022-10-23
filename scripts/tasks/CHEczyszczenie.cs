using Godot;
using System;

public class CHEczyszczenie : TaskWithGUI
{
    public override string GetResourceLocation()
    {
        return "res://gui/CHE-czyszczenie.tscn";
    }
    
    public override string ToString()
    {
        return "SALA CHEMICZNA: wyczyść probówki";
    }
    
    public CHEczyszczenie()
    {
        this.category = TaskCategory.Easy;
    }
}
