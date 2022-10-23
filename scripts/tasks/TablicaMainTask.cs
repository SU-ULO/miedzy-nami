using Godot;
using System;

public class TablicaMainTask : Task
{
    protected static bool debug = false;
    
    public TablicaMainTask()
    {
        
        if (debug == true)
        {
            this.local = true;
        }
        
        this.maxState = 1;
    }
    
    public override string ToString()
    {
        return "Wyczyść tablice (2)";
    }
    
    public override void _Ready()
    {
        int numberOfBoards = 0;
        
        foreach(Task t in Task.tasks)
        {
            if(t.GetType() == typeof(TablicaHelperTask))
            {
                numberOfBoards++;
            }
        }
        
        this.maxState = numberOfBoards;
    }
    
    public override void TaskOnCompleted()
    {
        Godot.GD.Print("Tablice completed");    
    }
    
    public override void TaskOnProgress(int progress)
    {
        Godot.GD.Print("Tablice progress "+state+"/"+maxState);
    }
}
