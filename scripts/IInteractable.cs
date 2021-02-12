using Godot;
using System;

public interface IInteractable
{
	void Interact();
	void EndInteraction();
	bool IsDone();
}
