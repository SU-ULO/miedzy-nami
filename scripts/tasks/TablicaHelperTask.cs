using Godot;
using System;

public class TablicaHelperTask : TaskWithGUI
{
    public override string GetResourceLocation()
    {
        return "res://gui/tablica.tscn";
    }
    
    public override bool Interact(Godot.Node2D body)
    {
        TablicaMainTask mainTablicaTask = (TablicaMainTask)GetTasksOfType(typeof(TablicaMainTask))[0];
        bool mainLocal = mainTablicaTask.local;
        
        if(mainLocal)
        {
            TaskInteract(body);
        }
        
        return mainLocal;
    }
    
    public TablicaHelperTask()
    {
        this.started = false;
    }
    
    public override void TaskOnCompleted()
    {
        TablicaMainTask mainTablicaTask = (TablicaMainTask)GetTasksOfType(typeof(TablicaMainTask))[0];
        mainTablicaTask.state += 1;
    }
}
