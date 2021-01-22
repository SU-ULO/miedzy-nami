
using System;
using System.Collections.Generic;

public abstract class Task : Godot.Node2D
{
	private static int currentTaskID = 0;
	private static Random r = new Random();
	public static List<Task> tasks = new List<Task>();

	public static List<List<Task>> DivideTasks(int numberOfPlayers){
		int numberOfTaskCategories = Enum.GetValues(typeof(TaskCategory)).GetLength(0);
		List<Task>[] sortedIntoCategories = new List<Task>[numberOfTaskCategories];
		List<Task>[] leftovers = new List<Task>[numberOfTaskCategories];
		
		for(int i = 0; i < numberOfTaskCategories; i++){
			sortedIntoCategories[i] = new List<Task>();
			leftovers[i] = new List<Task>();
		}
		
		List<List<Task>> players = new List<List<Task>>();
		for(int i = 0; i < numberOfPlayers; i++){
			players.Add(new List<Task>());
		}
		
		Godot.GD.Print(tasks.Count);
		
		for(int i = 0; i < tasks.Count; i++){
			sortedIntoCategories[(int)tasks[i].category].Add(tasks[i]);
		}
		
		// Try to evenly divide the tasks
		
		for(int i = 0; i < numberOfTaskCategories; i++){
			List<Task> category = sortedIntoCategories[i];
			
			int numberOfTasksPerPlayer = category.Count / numberOfPlayers;
			
			for(int j = 0; j < numberOfPlayers; j++){
				Godot.GD.Print(i + " " + j +  " " + category.Count + " " + numberOfTasksPerPlayer);
				for(int k = 0; k < numberOfTasksPerPlayer; k++){
					int index = r.Next(0, category.Count);
					
					players[j].Add(category[index]);
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
				foreach (Task t in players[i])
					playerDifficulties[i] += ((int) t.category + 1);
			}
			else
			{
				playerDifficulties[i] = playerDifficulties[0];
			}
		}
		
		// Distribute the remaining tasks
		for(int i = 0; i < numberOfTaskCategories; i++){
			for(int j = 0; j < leftovers[i].Count; j++){
				// Roll how many players should get the task
				int howManyTimes = r.Next(1,3);
				for(int k = 0; k < howManyTimes; k++){
					// Search for the player with the lowest difficulty score
					int minIndex = -1;
					for(int l = 0; l < numberOfPlayers; l++){
						// Reject any player, that already has this task on the list
						if(!players[l].Contains(leftovers[i][j])){
							if(minIndex == -1 || playerDifficulties[minIndex] > playerDifficulties[l])
								minIndex = l;
						}
					}
					
					// Add the task and adjust the difficulty score
					players[minIndex].Add(leftovers[i][j]);
					// (We don't want anyone to get too many tasks, 
					// even if they're simple, so the additional tasks add more score)
					playerDifficulties[minIndex] += ((int) leftovers[i][j].category + 5);
				}	
			}
		}
		
		return players;
	}

	public int state { get; set; }
	public int maxState { get; protected set; }
	protected bool started = false;
	protected int taskID;
	
	public void Start(){
		started = true;
		state = 0;
	}
	
	public Task(){
		started = false;
		taskID = currentTaskID;
		currentTaskID++;
		tasks.Add(this);
	}
	
	public enum TaskCategory{
		VeryHard = 3,
		Hard = 2,
		Medium = 1,
		Easy = 0
	}

	public TaskCategory category;
	
	public virtual void TaskInteract(){

	}
}

public class TaskTest : Task {
	

}
