using System;
using System.IO;

public abstract class ButtonBasedCustomizer : Godot.Node
{
	[Godot.Export]
	protected string atlasBase = null;
	
	/* i give up here */
	
	public void GenerateButtons(Godot.GridContainer gridContainer, int colorIndex)
	{
		foreach(var atlas in TextureAtlasHandler.AtlasFrameSets)
		{
			string atlasName = atlas.Key;
			if (!atlasName.StartsWith(atlasBase))
				continue;
			
			string atlasPath = atlas.Value.RelResourcePath;
			
			string buttonName = Path.GetFileName(atlasPath);
			
			Godot.Button button = new Godot.Button();

			button.Icon = TextureAtlasHandler.GetTextureFromAtlas(atlasName, colorIndex);
			button.SizeFlagsHorizontal = 0;
			button.SizeFlagsVertical = 0;
			button.RectScale = new Godot.Vector2(0.2f, 0.2f);
			
			gridContainer.AddChild(button);			
		}
		
		gridContainer.Columns = 8;
	}
	
	public static void Wrapper(Godot.Node selectedMenu, Godot.GridContainer container, int colorIndex)
	{
		if (typeof(ButtonBasedCustomizer).IsInstanceOfType(selectedMenu))
		{
			ButtonBasedCustomizer customizer = (ButtonBasedCustomizer) selectedMenu;
			customizer.GenerateButtons(container, 0);
		}
	}
}
