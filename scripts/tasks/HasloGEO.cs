using Godot;
using System;

public class HasloGEO : TaskWithGUI
{
    public override string GetResourceLocation()
    {
        return "res://gui/haslo.tscn";
    }
    
    public override string ToString()
    {
        return "SALA GEOGRAFICZNA: odblokuj komputer (3/3)";
    }
    
    public HasloGEO()
    {
        started = false;
    }
}
