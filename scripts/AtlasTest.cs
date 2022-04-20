using Godot;
using System;

public class AtlasTest : Button
{	
	bool clicked = false;
	
	private void OnButtonPressed()
	{
		TextureAtlasHandler handler = (TextureAtlasHandler)this.GetParent();
		
		handler._Ready();
		
		foreach (var info in TextureAtlasHandler.AtlasFrameSets.Values)
		{	
			this.Icon = TextureAtlasHandler.GetTextureFromAtlas(info.RelResourcePath, 0);
			// TextureAtlasHandler.CloseTexture(this.Icon);
			this.Icon = null;
		}
		
		GC.Collect();
		GC.WaitForPendingFinalizers();
		GC.Collect();
	}
}
