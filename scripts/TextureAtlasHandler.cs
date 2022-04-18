using Godot;
using System;
using System.Collections.Generic;

/* a quick and hacky implementation of texture atlasing */

public partial class TextureAtlasHandler : Node
{
	class TextureDictionaryEntry
	{
		public int occurences;
		public Texture[] textures = null;
		public Texture AtlasBase;
		public AtlasInfo Info;
		
		public TextureDictionaryEntry(int occurences, Texture[] textures, Texture AtlasBase, AtlasInfo Info)
		{
			this.textures = textures;
			this.occurences = occurences;
			this.AtlasBase = AtlasBase;
			this.Info = Info;
		}
	}
	
	/* this variable holds currently loaded atlases */
	private static Dictionary<string, TextureDictionaryEntry> TextureAtlases = null;
	
	/* this variable holds information necessary to free textures */
	private static Dictionary<Texture, TextureDictionaryEntry> ReverseTextureAtlasMap = null;
	
	public class AtlasInfo 
	{
		public string RelResourcePath;
		public int ElementWidth;
		public int ElementHeight;	
	
		public AtlasInfo(string RelResourcePath, int ElementWidth, int ElementHeight)
		{
			this.RelResourcePath = RelResourcePath;
			this.ElementWidth = ElementWidth;
			this.ElementHeight = ElementHeight;	
		}
	}
	
	public void _Ready()
	{
		if (TextureAtlases == null)
		{
			TextureAtlases = new Dictionary<string, TextureDictionaryEntry>();	
			ReverseTextureAtlasMap = new Dictionary<Texture, TextureDictionaryEntry>();
		}	
	}
	
	public static Texture GetTextureFromAtlas(string atlasName, int textureIndex)
	{
		/* if this texture atlas is not loaded */
		if (!TextureAtlases.ContainsKey(atlasName))
		{
			string baseAtlasName = atlasName;
			
			AtlasInfo info = AtlasFrameSets[baseAtlasName];
			string resourcePath = "res://textures/" + info.RelResourcePath + "/";
			
			resourcePath += "atlas.png";
			
			Texture atlasBase = (Texture)GD.Load(resourcePath);
			if (atlasBase == null)
				throw new System.IO.FileNotFoundException("Atlas file not found", resourcePath);

			AtlasTexture[] atlasTextures = new AtlasTexture[(atlasBase.GetWidth() / info.ElementWidth) * (atlasBase.GetHeight() / info.ElementHeight)];
			for (int i = 0; i < atlasTextures.Length; i++)
				atlasTextures[i] = null;
			
			TextureDictionaryEntry entry = new TextureDictionaryEntry(0, atlasTextures, atlasBase, info);
			TextureAtlases.Add(atlasName, entry);
		}
		
		/* if this texture is not loaded */
		if (TextureAtlases[atlasName].textures[textureIndex] == null)
		{	
			AtlasTexture atlasTexture = new AtlasTexture();
			Texture atlasBase = TextureAtlases[atlasName].AtlasBase;
			AtlasInfo info = TextureAtlases[atlasName].Info;
			
			int xIndex, yIndex;
			
			xIndex = textureIndex % (atlasBase.GetWidth() / info.ElementWidth);
			yIndex = textureIndex / (atlasBase.GetWidth() / info.ElementWidth);
			
			atlasTexture.Atlas = atlasBase;
			atlasTexture.Region = new Rect2(
				xIndex * info.ElementWidth,
				yIndex * info.ElementHeight,
				info.ElementWidth,
				info.ElementHeight
			);	
			
			TextureAtlases[atlasName].textures[textureIndex] = atlasTexture;
		}
		
		Texture texture = TextureAtlases[atlasName].textures[textureIndex];
		
		if (ReverseTextureAtlasMap.ContainsKey(texture) == false)
		{
			ReverseTextureAtlasMap.Add(texture, TextureAtlases[atlasName]);
		}
		else if (ReverseTextureAtlasMap[texture] != TextureAtlases[atlasName])
		{
			/* critical error, TODO: handle */
		}
		
		TextureAtlases[atlasName].occurences++;
		return texture;
	}
	
	/* dereferences the texture atlas this texture is in and performs cleanup if necessary */
	public static void CloseTexture(Texture texture)
	{
		/* if we have this texture loaded */
		if (ReverseTextureAtlasMap.ContainsKey(texture))
		{
			ReverseTextureAtlasMap[texture].occurences--;
			if (ReverseTextureAtlasMap[texture].occurences == 0)
			{
				TextureDictionaryEntry entry = ReverseTextureAtlasMap[texture];
				
				for (int i = 0; i < entry.textures.Length; i++)
				{
					entry.textures[i] = null;
				}
			
				List<string> keysToRemove = new List<string>();
			
				/* create a list of every key that has the value to be deleted... */	
				foreach (KeyValuePair<string, TextureDictionaryEntry> kvp in TextureAtlases)
				{
					if (kvp.Value == entry)
					{
						keysToRemove.Add(kvp.Key);
					}
				}
				
				/* and remove all of them */
				foreach (string toRemove in keysToRemove)
				{	
					TextureAtlases.Remove(toRemove);
				}
				
				ReverseTextureAtlasMap.Remove(texture);
				
				/* force the garbage collection */
				GC.Collect();
				GC.WaitForPendingFinalizers();
				GC.Collect();
			}
		}
	}
}
