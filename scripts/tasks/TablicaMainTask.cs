using Godot;
using System;

public class TablicaMainTask : Task
{
	protected static bool debug = true;
	
	public TablicaMainTask(){
		
		if (debug == true){
			this.local = true;
		}
		
		int numberOfBoards = 0;
		
		foreach(Task t in Task.tasks){
			if(t.GetType() == typeof(TablicaHelperTask)){
				numberOfBoards++;
			}
		}
		
		this.maxState = numberOfBoards;
	}
	
	public override void TaskOnCompleted(){
		Godot.GD.Print("Tablice completed");	
	}
	
	public override void TaskOnProgress(int progress){
		Godot.GD.Print("Tablice progress "+state+"/"+maxState);
	}
}
