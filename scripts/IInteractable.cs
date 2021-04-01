using Godot;
using System;

public interface IInteractable
{
	bool Interact(Godot.Node2D body);
	void EndInteraction(Godot.Node2D body);
	bool IsDone();
}
