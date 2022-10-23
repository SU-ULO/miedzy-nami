using Godot;
using System;

public class INFdebug : TaskWithGUI
{
    public override string GetResourceLocation()
    {
        return "res://gui/INF-debug.tscn";
    }
    
    public override string ToString()
    {
        return "SALA INFORMATYCZNA: zdebugguj kod twojego programu";
    }
    
    public INFdebug()
    {
        this.category = TaskCategory.Easy;
    }
}
