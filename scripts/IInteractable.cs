using Godot;
using System;

public interface IInteractable
{
	bool Interact();
	void EndInteraction();
	bool IsDone();
}
