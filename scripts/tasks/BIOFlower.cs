using Godot;
using System;

public class BIOFlower : TaskWithGUI
{
    public override string GetResourceLocation()
    {
        return "res://gui/BIO-Flower.tscn";
    }
    
    public override string ToString()
    {
        return "SALA BIOLOGICZNA: podlej kwiatki";
    }
    
    public BIOFlower()
    {
        this.category = TaskCategory.Easy;
    }
}
