using Godot;
using System;
using System.Collections.Generic;

/* a quick and hacky implementation of texture atlasing */

public partial class TextureAtlasHandler : Node
{
	public static string AtlasRoot = "res://textures/";
	
	class TextureDictionaryEntry
	{
		public int occurences;
		public Texture[] textures = null;
		public AtlasInfo Info;
		
		public TextureDictionaryEntry(int occurences, Texture[] textures, AtlasInfo Info)
		{
			this.textures = textures;
			this.occurences = occurences;
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
		
		public string ResourcePath
		{
			get { return AtlasRoot + this.RelResourcePath + "/atlas.png"; }
			
		}
	}
	
	public static void CheckAndInit()
	{
		if (TextureAtlases == null)
		{
			TextureAtlases = new Dictionary<string, TextureDictionaryEntry>();	
			ReverseTextureAtlasMap = new Dictionary<Texture, TextureDictionaryEntry>();
		}	
	}
	
	public new void _Ready()
	{
		CheckAndInit();		
	}
	
	private static void CreateTextureAtlasEntry(string atlasName)
	{		
		CheckAndInit();				
		AtlasInfo info = AtlasFrameSets[atlasName];
		
		string resourcePath = info.ResourcePath;
		
			
		Texture atlasBase = (Texture)GD.Load(resourcePath);
		if (atlasBase == null)
			throw new System.IO.FileNotFoundException("Atlas file not found", resourcePath);

		Texture[] atlasTextures = new Texture[(atlasBase.GetWidth() / info.ElementWidth) * (atlasBase.GetHeight() / info.ElementHeight)];
		for (int i = 0; i < atlasTextures.Length; i++)
			atlasTextures[i] = null;
			
		TextureDictionaryEntry entry = new TextureDictionaryEntry(0, atlasTextures, info);
		TextureAtlases.Add(atlasName, entry);	
	}
	
	public static Texture GetTextureFromAtlas(string atlasName, int textureIndex)
	{
		CheckAndInit();				
		
		/* if this texture atlas is not loaded */
		if (!TextureAtlases.ContainsKey(atlasName))
		{
			CreateTextureAtlasEntry(atlasName);
		}
		
		/* if this texture is not loaded */
		if (TextureAtlases[atlasName].textures[textureIndex] == null)
		{	
			ImageTexture outTexture = new ImageTexture();
			AtlasInfo info = TextureAtlases[atlasName].Info;
			Texture atlasBase = (Texture)GD.Load(info.ResourcePath);
			
			int xIndex, yIndex;
			
			xIndex = textureIndex % (atlasBase.GetWidth() / info.ElementWidth);
			yIndex = textureIndex / (atlasBase.GetWidth() / info.ElementWidth);
			
			Image image = new Image();
			image.Create(info.ElementWidth, info.ElementHeight, false, Image.Format.Rgba8);
			
			Image src = atlasBase.GetData();
			
			image.Lock();
			src.Lock();
			
			image.BlitRect(
				src, 
				new Rect2(xIndex * info.ElementWidth, yIndex * info.ElementHeight, info.ElementWidth, info.ElementHeight),
				new Vector2(0, 0)
			);
			
			src.Unlock();
			image.Unlock();
			
			outTexture.CreateFromImage(image);
			
			TextureAtlases[atlasName].textures[textureIndex] = (Texture)outTexture;
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
		CheckAndInit();		
		
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
	
	public static Resource LoadOverride(string path)
	{
		int lastSlash = path.LastIndexOf('/');
		string pathParsed, lastWord;
		
		try
		{
			if (lastSlash > 0)
			{
				pathParsed = path.Substring(0, lastSlash);
				lastWord = path.Substring(lastSlash + 1);
			}
			else
			{
				pathParsed = "";
				lastWord = path;	
			}
			
			if (pathParsed.BeginsWith(AtlasRoot))
			{
				pathParsed = pathParsed.Substring(AtlasRoot.Length);
				
				int startOfIndexString = lastWord.IndexOfAny("0123456789".ToCharArray());
				int endOfIndexString = lastWord.LastIndexOfAny("0123456789".ToCharArray());
					
				string indexString = "";
					
				try 
				{
					indexString = lastWord.Substring(startOfIndexString, endOfIndexString - startOfIndexString + 1);
				}
				catch(Exception e)
				{
					/* handle edge cases here */
					indexString = "0";
				}
				
				int index = 0;
				
				try 
				{
					index = Int32.Parse(indexString);
				}
				catch (Exception e)
				{
					throw new Exception(indexString + " is not a valid number");
				}
				
				return GetTextureFromAtlas(pathParsed, index);
			}
		}
		catch (Exception e)
		{
			GD.Print(e.ToString());
		}
		
		return (Resource) GD.Load(path.Replace("/character/", "/charactera/"));	
	}
}
