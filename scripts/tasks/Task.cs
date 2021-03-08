
using System;
using System.Collections.Generic;
using System.Xml;
using System.Xml.Serialization;
using System.IO;

public abstract class Task : Godot.Node2D
{
	public static bool anyDirty = false;
	
	public static bool CheckAndClearAnyDirty(){
		bool tmp = anyDirty;
		anyDirty = false;
		return tmp;
	}
	
	public bool dirty = false;
	
	public bool Dirty{
		get{
			return dirty;
		}
		set {
			dirty = value;
		}
	}
	
	public bool local = false;
	
	public bool Local{
		get{
			return local;
		}
		set {
			local = value;
		}
	}
	
	private static int currentTaskID = 0;
	private static Random r = new Random();
	public static List<Task> tasks = new List<Task>();
	public static List<int>[] tasksForPlayers = null;
	
	public static int[] GetTaskIDsForPlayerID(int playerID){
		Godot.GD.Print("GetTaskIDsForPlayerID: " + playerID + " " + tasksForPlayers.Length);
		Godot.GD.Print("N"+tasksForPlayers[playerID].Count);
		return tasksForPlayers[playerID].ToArray();
	}

	public static Task[] GetTasksOfType(Type c){
		List<Task> result = new List<Task>();
		
		Godot.GD.Print("Enumerating total of "+ tasks.Count + " looking for tasks of type " + c.Name);
		
		foreach (Task task in tasks){
			if(task.GetType().Equals(c))
				result.Add(task);
		}
		
		return result.ToArray();
	}
	
	public static Task GetTaskByID(int id){
		
		foreach (Task task in tasks){
			if(task.taskID == id)
				return task;
		}
		
		Godot.GD.Print("Task with ID "+ id + " not found in " + tasks.Count + " tasks.");
		
		return null;
	}
	
	public static Task[] GetAllTasks(){
		return tasks.ToArray();
	}

	public static void Cleanup(){
		tasks.Clear();
		currentTaskID = 0;
	}
	
	public virtual int GetNextTaskID(){
		return this.taskID;
	}

	public static void DivideTasks(int[] playerIDs){
		int numberOfPlayers = playerIDs.Length;
		int numberOfTaskCategories = Enum.GetValues(typeof(TaskCategory)).GetLength(0);
		List<int>[] sortedIntoCategories = new List<int>[numberOfTaskCategories];
		List<int>[] leftovers = new List<int>[numberOfTaskCategories];
		tasksForPlayers = new List<int>[numberOfPlayers];
		
		for(int i = 0; i < numberOfTaskCategories; i++){
			sortedIntoCategories[i] = new List<int>();
			leftovers[i] = new List<int>();
		}
		
		for(int i = 0; i < numberOfPlayers; i++){
			tasksForPlayers[i] = (new List<int>());
		}
		
		Godot.GD.Print("Total tasks: "+tasks.Count);
		
		for(int i = 0; i < tasks.Count; i++){
			// Don't add any tasks, that require another one to be done first
			if(tasks[i].started)
				sortedIntoCategories[(int)tasks[i].category].Add(tasks[i].taskID);
		}
		
		// Try to evenly divide the tasks
		
		for(int i = 0; i < numberOfTaskCategories; i++){
			List<int> category = sortedIntoCategories[i];
			
			int numberOfTasksPerPlayer = category.Count / numberOfPlayers;
			
			for(int j = 0; j < numberOfPlayers; j++){
				Godot.GD.Print(i + " " + j +  " " + category.Count + " " + numberOfTasksPerPlayer);
				for(int k = 0; k < numberOfTasksPerPlayer; k++){
					int index = r.Next(0, category.Count);
					
					tasksForPlayers[j].Add(category[index]);
					category.Remove(category[index]);
				}
			}
			
			leftovers[i] = category;
		}
		
		// Calculate how difficult the tasks are for the given user.
		int[] playerDifficulties = new int[numberOfPlayers];
		
		for(int i = 0; i < numberOfPlayers; i++){
			if(i == 0)
			{
				foreach (int t in tasksForPlayers[i])
					playerDifficulties[i] += ((int) tasks[t].category + 1);
			}
			else
			{
				playerDifficulties[i] = playerDifficulties[0];
			}
		}
		
		// Distribute the remaining tasks
		for(int i = 0; i < numberOfTaskCategories; i++){
			for(int j = 0; j < leftovers[i].Count; j++){
				// Roll how many tasksForPlayers should get the task
				int howManyTimes = r.Next(1,3);
				for(int k = 0; k < howManyTimes; k++){
					// Search for the player with the lowest difficulty score
					int minIndex = -1;
					for(int l = 0; l < numberOfPlayers; l++){
						// Reject any player, that already has this task on the list
						if(!tasksForPlayers[l].Contains(leftovers[i][j])){
							if(minIndex == -1 || playerDifficulties[minIndex] > playerDifficulties[l])
								minIndex = l;
						}
					}
					
					Task taskToAdd = tasks[leftovers[i][j]];
					// Add the task and adjust the difficulty score
					tasksForPlayers[minIndex].Add(taskToAdd.taskID);
					// (We don't want anyone to get too many tasks, 
					// even if they're simple, so the additional tasks add more score)
					playerDifficulties[minIndex] += ((int) taskToAdd.category + 5);
				}	
			}
		}
		
		for(int i = 0; i < numberOfPlayers; i++){
			for(int j = 0; j < tasksForPlayers[i].Count; j++){
				tasks[tasksForPlayers[i][j]].playerIDs.Add(playerIDs[i]);
			}
		}

	}

	public List<int> playerIDs = new List<int>();
	private int _state;
	public int state { 
		get {
			return _state;
		} 
		set {
			Godot.GD.Print("Setting task "+taskID+" state to "+value+" out of "+maxState);
			_state = value;
			TaskOnProgress(value - _state);
			if(value >= maxState){
				if (this.local){
					TaskOnCompleted();
					Task.anyDirty = true;
					this.dirty = true;
					
					if(this.GetNextTaskID() != this.taskID){
						Task nextTask = tasks[this.GetNextTaskID()];
						nextTask.dirty = true;
						nextTask.started = true;
					}
					
					Godot.GD.Print("Ending task "+taskID);
					TaskEndInteraction();
					return;
				}
			}
		} 
	}
	public int maxState { get; set; }
	protected bool started = true;
	public int taskID { get; set; }
	
	public Task(){
		if(this.GetType() != typeof(Task)){
			taskID = currentTaskID;
			currentTaskID++;
			tasks.Add(this);
		}else{
			Godot.GD.Print("Creating implementationless instance of Task (probably for using static members in GDScript)");
		}
	}
	
	public enum TaskCategory{
		VeryHard = 3,
		Hard = 2,
		Medium = 1,
		Easy = 0
	}

	public TaskCategory category;
	
	public virtual void TaskInteract(){}
	public virtual void TaskEndInteraction(){}
	public virtual void TaskOnProgress(int progress){}
	public virtual void TaskOnCompleted(){}
	
	public virtual string ToString(){
		return "Task-"+taskID+" started status: "+started+" of category"+category;
	}
	
		
	public bool IsDone(){
		return this.state >= this.maxState;
	}

}
