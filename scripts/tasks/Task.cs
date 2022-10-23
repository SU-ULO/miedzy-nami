using System;
using System.Collections.Generic;
using System.Xml;
using System.Xml.Serialization;
using System.IO;

public abstract class Task : Godot.Node2D
{
    public static bool anyDirty = false;
    
    public Godot.Node2D player = null;

    public static bool CheckAndClearAnyDirty()
    {
        bool tmp = anyDirty;
        anyDirty = false;
        return tmp;
    }
    
    public bool dirty = false;
    
    public bool Dirty
    {
        get
        {
            return dirty;
        }
        set 
        {
            dirty = value;
        }
    }
    
    public bool local = false;
    
    public bool Local
    {
        get
        {
            return local;
        }
        set 
        {
            local = value;
        }
    }
    
    private static int currentTaskID = 0;
    private static Random r = new Random();
    public static List<Task> tasks = new List<Task>();
    public static List<int>[] tasksForPlayers = null;
    
    public static int[] GetTaskIDsForPlayerID(int playerID)
    {
        Godot.GD.Print("GetTaskIDsForPlayerID: " + playerID + " " + tasksForPlayers.Length);
        Godot.GD.Print("N"+tasksForPlayers[playerID].Count);
        return tasksForPlayers[playerID].ToArray();
    }

    public static Task[] GetTasksOfType(Type c)
    {
        List<Task> result = new List<Task>();
        
        Godot.GD.Print("Enumerating total of "+ tasks.Count + " looking for tasks of type " + c.Name);
        
        foreach (Task task in tasks)
        {
            if(task.GetType().Equals(c))
            {
                result.Add(task);
            }
        }
        
        return result.ToArray();
    }
    
    private static Task TaskNotFound(Object criteria)
    {
        Godot.GD.Print("Task "+ criteria + " not found in " + tasks.Count + " tasks.");
        return null;
    }
    
    public static Task GetTaskByID(int id)
    {
        
        foreach (Task task in tasks)
        {
            if(task.taskID == id)
                return task;
        }
        
        return TaskNotFound(id);
    }
    
    public static Task GetTaskByTypeName(string typeName)
    {
        foreach (Task task in tasks)
        {
            if(task.GetType().Name == typeName)
                return task;
        }
        
        return TaskNotFound(typeName);
    }
    
    public static Task[] GetAllTasks()
    {
        return tasks.ToArray();
    }

    public static void ClientCleanup()
    {
        tasks.Clear();
        currentTaskID = 0;
    }
    
    public virtual int GetNextTaskID()
    {
        return this.taskID;
    }

    public static void DivideTasks(int[] playerIDs)
    {
        int maxPlayerPlusOne = 0;
        for(int i = 0; i < playerIDs.Length; i++)
        {
            if(maxPlayerPlusOne < playerIDs[i])
            {
                maxPlayerPlusOne = playerIDs[i];
            }
        }
        
        maxPlayerPlusOne++;
        
        Dictionary<TaskCategory, List<int>> sortedIntoCategories = new Dictionary<TaskCategory, List<int>>();
        tasksForPlayers = new List<int>[maxPlayerPlusOne];
        
        foreach(TaskCategory tc in TaskCategory.categories)
        {
            sortedIntoCategories.Add(tc, new List<int>());
        }
        
        for(int i = 0; i < maxPlayerPlusOne; i++)
        {
            tasksForPlayers[i] = (new List<int>());
        }
        
        Godot.GD.Print("Total tasks: "+tasks.Count);
        
        for(int i = 0; i < tasks.Count; i++)
        {
            Godot.GD.Print(tasks[i].ToString()+": "+tasks[i].started);
            // Don't add any tasks, that require another one to be done first
            if(tasks[i].started)
            {
                sortedIntoCategories[tasks[i].category].Add(tasks[i].taskID);
            }
        }
        
        foreach(TaskCategory tc in TaskCategory.categories)
        {
            if(sortedIntoCategories[tc].Count < tc.perPlayer)
            {
                tc.perPlayer = sortedIntoCategories[tc].Count;
            }
        }
        
        for (int i = 0; i < playerIDs.Length; i++)
        {
            foreach (TaskCategory tc in TaskCategory.categories)
            {
                if(sortedIntoCategories[tc].Count > 0)
                {
                    for(int j = 0; j < tc.perPlayer; j++)
                    {
                        int taskIDforK = 0, k = 0;
                        int initialK = 0;
                        try 
                        {
                            k = r.Next(0, sortedIntoCategories[tc].Count);
                            initialK = k;
                            taskIDforK = sortedIntoCategories[tc][k];
                            while(tasksForPlayers[playerIDs[i]].Contains(taskIDforK)) 
                            {
                                k = (k + 1) % sortedIntoCategories[tc].Count;
                                taskIDforK = sortedIntoCategories[tc][k];
                                if(k == initialK)
                                {
                                    //Godot.GD.Print("One of the tasks couldn't be assigned");
                                    throw new Exception("");
                                }
                            }
                            taskIDforK = sortedIntoCategories[tc][k];
                            tasksForPlayers[playerIDs[i]].Add(taskIDforK);
                            GetTaskByID(taskIDforK).playerIDs.Add(playerIDs[i]);
                        }
                        catch(Exception e)
                        {
                            if(e.Message.Equals("") == false)
                            {
                                Godot.GD.Print("Skopiuj ten błąd dla Marcina: "+e
                                +"\ntaskIDforK: "+taskIDforK
                                +"\nk: "+k
                                +"\nsortedIntoCategories[tc].Count: "+sortedIntoCategories[tc].Count
                                +"\ni: "+i
                                +"\nplayerIDs.Length"+playerIDs.Length);
                            }
                        }
                    }
                }
            }    
        }

    }

    public List<int> playerIDs = new List<int>();
    private int _state;
    
    public int state 
    { 
        get 
        {
            return _state;
        } 
        set 
        {
            Godot.GD.Print("Setting task "+taskID+" state to "+value+" out of "+maxState);
            _state = value;
            TaskOnProgress(value - _state);
            if(value >= maxState)
            {
                if (this.local)
                {
                    TaskOnCompleted();
                    Task.anyDirty = true;
                    this.dirty = true;
                    
                    if(this.GetNextTaskID() != this.taskID)
                    {
                        Task nextTask = tasks[this.GetNextTaskID()];
                        nextTask.dirty = true;
                        nextTask.started = true;
                        nextTask.local = true;
                    }
                    
                    Godot.GD.Print("Ending task "+taskID);
                    player.GetNode("GUI").Call("clear_canvas");
                    return;
                }
            }
        } 
    }
    public int maxState { get; set; }
    protected bool started = true;
    public int taskID { get; set; }
    
    public Task()
    {
        if(this.GetType() != typeof(Task))
        {
            taskID = currentTaskID;
            currentTaskID++;
            tasks.Add(this);
        }
        else
        {
            Godot.GD.Print("Creating implementationless instance of Task (probably for using static members in GDScript)");
        }
    }
    
    public class TaskCategory
    {
        // You can (un)define categories here
        // The number of tasks of given category per player is specified in perPlayer and can be changed
        // ADD THEM TO THE CATEGORIES ARRAY THOUGH (or declare them just there, but for ease of use's sake
        // it is generally a good idea to have them named here)
        public static TaskCategory VeryHard = new TaskCategory(0);
        public static TaskCategory Hard = new TaskCategory(0);
        public static TaskCategory Normal = new TaskCategory(0);
        public static TaskCategory Easy = new TaskCategory(0);
        
        public static readonly TaskCategory[] categories = new TaskCategory[]
        {
            VeryHard,
            Hard,
            Normal,
            Easy
        };
        
        public int perPlayer = 0;
        
        private TaskCategory(int perPlayer)
        {
            this.perPlayer = perPlayer;
        }
    }

    public TaskCategory category = TaskCategory.Normal;
    
    public virtual void TaskInteract(Godot.Node2D body){}
    public virtual void TaskEndInteraction(Godot.Node2D body){}
    public virtual void TaskOnProgress(int progress){}
    public virtual void TaskOnCompleted(){}
    
    public virtual string ToString()
    {
        return this.GetType().Name + " ["+state+"/"+maxState+"]";
    }
    
        
    public bool IsDone()
    {
        return this.state >= this.maxState;
    }

    public static void SetTaskCategoriesPerPlayer(int index, int value)
    {
        TaskCategory.categories[index].perPlayer = value;
    }
    
    public int taskLength = 1;
}
