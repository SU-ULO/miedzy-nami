using Godot;
using System;

public class EyeCustomizer : ButtonBasedCustomizer
{
	public EyeCustomizer()
	{
		_Ready();
	}
	
	public new virtual void _Ready()
	{
		this.atlasBase = "character/face parts/oczy/frame1";	
	}
}
