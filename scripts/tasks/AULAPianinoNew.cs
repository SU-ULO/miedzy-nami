using Godot;
using System;
using System.Collections.Generic;

public class AULAPianinoNew : Control
{
    public List<Control> PianoParts = new List<Control>();
    public Dictionary<string, Control> KeyControlMapping = new Dictionary<string, Control>();

    internal StyleBoxFlat noteSbf = new StyleBoxFlat();
    internal StyleBoxFlat backgroundSbf = new StyleBoxFlat();
    internal StyleBoxFlat endNoteSbf = new StyleBoxFlat();
    
    public AULAPianinoNew()
    {
        noteSbf.SetBgColor(new Color(0.5f, 0.5f, 0.0f));
        backgroundSbf.SetBgColor(new Color(0.0f, 0.0f, 0.0f, 0.0f));        
        endNoteSbf.SetBgColor(new Color(0.0f, 0.0f, 0.0f, 0.0f));        
    }

    public Vector2 DisplaySize 
    {
        get { return this.RectSize; }
    }
    
    private float NoteLength
    {
        get { return DisplaySize.y / 2.0f; }
    }
    
    private float NotesPerSecondsLength
    {
        get { return NoteLength * 0.75f; }
    }
    
    private Control NotesPanel = null;    
    
    public override void _Ready()
    {
        foreach (Node n in this.GetChildren())
        {
            if ((n is Control) == false)
                continue;
            
            Control c = (Control) n;
                
            if (c.HasNode("Keys") == false)
                continue;
            
            PianoParts.Add(c);
            
            foreach (Control key in c.GetNode("Keys").GetChildren())
            {
                KeyControlMapping.Add(c.Name + "" + key.Name, key);
                key.Connect("pressed", this, "ButtonPressed", new Godot.Collections.Array(){c.Name + "" + key.Name});
            }
        }
        
        this.Retry();
    }
    
    public override void _PhysicsProcess(float timeDelta)
    {
        if (NotesPanel == null)
            return;
        
        NotesPanel.RectPosition = new Vector2(
            NotesPanel.RectPosition.x, 
            NotesPanel.RectPosition.y + NotesPerSecondsLength * timeDelta
        );
    }
    
    private void Win()
    {
        GD.Print("piano win");
        TaskWithGUI.TaskWithGUICompleteTask(this);
        foreach (Node child in this.GetChildren())
            RecursivelyQueueFree(child);
        NotesPanel = null;
    }
    
    private void KillTile(PianoNote n)
    {
        n.GetParent().RemoveChild(n);
        n.QueueFree();
    }
    
    public void ButtonPressed(string buttonName)
    {
        Control c = KeyControlMapping[buttonName];
        
        int partNum = Int32.Parse(c.GetParent().GetParent().Name);
        
        foreach (Node n in NotesPanel.GetChildren())
        {
            if (n is PianoNote)
            {
                PianoNote pianoNote = (PianoNote) n;
                
                if (pianoNote is EndPianoNote)
                    continue;
                /* check if this note is even the right one for this piano key */
                if (pianoNote.note.KeyName.Equals(c.Name) && partNum == pianoNote.note.PianoPart)
                {
                    Rect2 globalRect = pianoNote.GetGlobalRect();
                    
                    /* a matching tile is found  */
                    if (globalRect.Position.y + globalRect.Size.y > this.GetNode<Panel>("Panel").GetGlobalRect().Position.y)
                    {
                        PlayKeyAnimation(c, "good", 5);
                        pianoNote.note.Play(GetNode<AudioStreamPlayer>("AudioStreamPlayer").Stream, this);
                        KillTile(pianoNote);
                        return;
                    }
                }
            }
        }    
        
        PlayKeyAnimation(c, "bad", 1);
        Retry();
    }

    internal class Note
    {
        internal string KeyName;
        internal int PianoPart;
        internal float Length;
        
        internal Note(string name, int part, float len)
        {
            KeyName = name;
            PianoPart = part;
            Length = len;
        }
        
        private static readonly Dictionary<string, int> KeyNameToNoteIndexMap = new Dictionary<string, int>()
        {
            {"c", 0},
            {"cis", 1},
            {"d", 2},
            {"dis", 3},
            {"e", 4},
            {"f", 5},
            {"fis", 6},
            {"g", 7},
            {"gis", 8},
            {"a", 9},
            {"ais", 10},
            {"h", 11}
        };
        
        private readonly int OctaveBase = 3;
        
        public void Play(AudioStream stream, Node parent)
        {
            int octave = PianoPart - OctaveBase;
            int noteIndex = KeyNameToNoteIndexMap[this.KeyName];
            
            AudioStreamPlayer player = new AudioStreamPlayer();
            parent.AddChild(player);
            player.Connect("finished", parent, "KillAudioStreamPlayer", new Godot.Collections.Array(){player});
            
            player.Stream = stream;
            player.PitchScale = (float)Math.Pow(2.0f, (octave * 12.0f + (float)noteIndex) / 12.0f);
            player.Play();
        }
    }

    public void KillAudioStreamPlayer(AudioStreamPlayer p)
    {
        this.RemoveChild(p);
        p.QueueFree();
    }

    private Vector2[] GetKeyRectGuidlineFromNote(Note note)
    {
        Control part = (Control)GetNode(note.PianoPart.ToString());
        Control keys = (Control)part.GetNode("Keys");    
        Control key = (Control)keys.GetNode(note.KeyName);
        Control guideline = (Control)key.GetNode("guideline");
        
        Rect2 globalRect = guideline.GetGlobalRect();
        
        Vector2[] result = new Vector2[]
        {
            globalRect.Size,
            globalRect.Position
        };
        
        return result;
    }

    class PianoNote : Panel
    {
        public delegate void OnFailure(int part, string keyName);
        public OnFailure onFailureHandler;
        
        protected AULAPianinoNew piano;
    
        public Note note;
    
        public PianoNote(Note note, AULAPianinoNew piano)
        {
            this.note = note;
            this.piano = piano;
        }
        
        internal PianoNote(){}
    
        public override void _PhysicsProcess(float delta)
        {
            Rect2 globalRect = this.GetGlobalRect();
            
            if (globalRect.Position.y > piano.DisplaySize.y - piano.GetNode<Panel>("Panel").GetGlobalRect().Size.y)
            {
                onFailureHandler(note.PianoPart, note.KeyName);
                this.QueueFree();
            }
        }
    }
    
    class EndPianoNote : PianoNote
    {        
        public EndPianoNote(AULAPianinoNew piano)
        {
            this.piano = piano;
        }
        
        public override void _PhysicsProcess(float delta)
        {
            Rect2 globalRect = this.GetGlobalRect();
            
            if (globalRect.Position.y > piano.DisplaySize.y * 0.5f - piano.GetNode<Panel>("Panel").GetGlobalRect().Size.y)
            {
                onFailureHandler(0, "end");
                this.QueueFree();
            }
        }
    }
    
    /* this could be done differently but it is 00:31 AM */
    private static void RecursivelyQueueFree(Node d)
    {
        foreach (Node n in d.GetChildren())
            RecursivelyQueueFree(n);
            
        d.QueueFree();
    }

    public void Retry()
    {
        /* cleanup */
        if (this.HasNode("background"))
        {
            NotesPanel = null;
            Node b = this.GetNode("background");
            this.RemoveChild(b);
            RecursivelyQueueFree(b);
        }
        
        List<Note[]> megalovania = new List<Note[]>()
        {
            new Note[]{new Note("d", 2, 1.0f)},
            new Note[]{new Note("d", 2, 1.0f)},
            new Note[]{new Note("d", 3, 1.0f)},
            new Note[]{new Note("a", 2, 1.0f)},
            new Note[]{new Note("gis", 2, 1.0f)},
            new Note[]{new Note("g", 2, 1.0f)},
            new Note[]{new Note("f", 2, 1.0f)},
            new Note[]{new Note("d", 2, 1.0f)},
            new Note[]{new Note("f", 2, 1.0f)},
            new Note[]{new Note("g", 2, 1.0f)}
        };
        
        List<Note[]> rickroll = new List<Note[]>()
        {
            new Note[]{new Note("f", 3, 1.0f)},
            new Note[]{new Note("g", 3, 1.0f)},
            new Note[]{new Note("c", 3, 1.0f)},
            new Note[]{new Note("g", 3, 1.0f)},
            new Note[]{new Note("a", 3, 1.0f)},
            new Note[]{new Note("a", 3, 1.0f)},
            new Note[]{new Note("c", 4, 1.0f)},
            new Note[]{new Note("ais", 3, 1.0f)}
        };
        
        List<Note[]>[] songs = new List<Note[]>[]
        {
            megalovania,
            rickroll
        };
        
        Random r = new Random();
        
        this.GenerateNotes(songs[r.Next(0, songs.Length)]);
    }

    private static void PlayKeyAnimation(Control c, string animationName, float speed)
    {
        AnimationPlayer animation = (AnimationPlayer) c.GetNode("animation");
            
        /* focefully stop all playing animations */
        if (animation.IsPlaying())
        {
            animation.Stop();
        }
        animation.ClearQueue();
        
        /* play the selected animation */
        animation.PlaybackSpeed = speed;
        animation.Play(animationName);
        
    }

    private void OnKeyFailure(int pianoPart, string keyName)
    {
        string fullKeyName = pianoPart.ToString() + keyName;
        PlayKeyAnimation(KeyControlMapping[fullKeyName], "bad", 1);
        Retry();
    }
    
    private void WinHandler(int pianoPart, string keyName)
    {
        Win();
    }

    private void GenerateNotes(List<Note[]> layers)
    {
        Node2D background = new Node2D();
        background.Name = "background";
        
        float notesSize = NoteLength * layers.Count;
        
        NotesPanel = new Panel();
        NotesPanel.RectSize = new Vector2(DisplaySize.x, notesSize);
        NotesPanel.RectPosition = new Vector2(0, -notesSize);
        NotesPanel.AddStyleboxOverride("panel", backgroundSbf);
        NotesPanel.MouseFilter = Control.MouseFilterEnum.Ignore;
        
        int currentLayer = 0;
        
        foreach (Note[] layer in layers)
        {
            float currentYPosition = (layers.Count - currentLayer - 1) * NoteLength;
            
            foreach (Note note in layer)
            {
                Vector2[] rectData = GetKeyRectGuidlineFromNote(note);
                
                PianoNote notePanel = new PianoNote(note, this);
                notePanel.RectSize = new Vector2(rectData[0].x, NoteLength * note.Length);
                notePanel.RectPosition = new Vector2(rectData[1].x, currentYPosition);
                notePanel.onFailureHandler = this.OnKeyFailure;
                notePanel.MouseFilter = Control.MouseFilterEnum.Ignore;
                notePanel.Name = note.PianoPart + note.KeyName;
                
                notePanel.AddStyleboxOverride("panel", noteSbf);
                
                NotesPanel.AddChild(notePanel);
            }
        
            currentLayer++;
        }

        EndPianoNote endNote = new EndPianoNote(this);
        endNote.RectSize = new Vector2(0, NoteLength);
        endNote.RectPosition = new Vector2(0, -NoteLength);
        endNote.onFailureHandler = this.WinHandler;
        endNote.MouseFilter = Control.MouseFilterEnum.Ignore;
        endNote.Name = "end";
        endNote.AddStyleboxOverride("panel", endNoteSbf);
        NotesPanel.AddChild(endNote);
        
        background.AddChild(NotesPanel);
        background.ZIndex = -1;
        
        this.AddChild(background);
    }

}
