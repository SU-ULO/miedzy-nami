using Godot;
using System;

public class ChatPanel : Control
{
	private bool originalMovement = true;
	
	public override void _Ready()
	{
		Node network = (Node)GetTree().GetRoot().GetNode("Start").Get("network");	
		network.Connect("gui_sync", this, "HandleGUISync");
	}
	
	private void SetMovement(bool m){
		Node network = (Node)GetTree().GetRoot().GetNode("Start").Get("network");
		((Node2D)network.Get("own_player")).Set("disabled_movement", !m);
	}
	
	private bool GetMovement(){
		Node network = (Node)GetTree().GetRoot().GetNode("Start").Get("network");
		return (bool)((Node2D)network.Get("own_player")).Get("disabled_movement");
	}
	
	void HandleGUISync(string guiName, Godot.Collections.Dictionary<string, object> data){
		Node network = (Node)GetTree().GetRoot().GetNode("Start").Get("network");
		Node2D player = ((Node2D)network.Get("own_player"));
		
		if(guiName.Equals("chat")){
			RichTextLabel chat = (RichTextLabel)GetNode("ChatContainer/Chat");	
			if(data.ContainsKey("append")){
				if(data.ContainsKey("dead"))
					if(data["dead"] == true && ((bool)player.Get("dead")) == false)
						return;
				chat.Text += data["append"].ToString();
			}else if(data.ContainsKey("set")){
				chat.Text = data["set"].ToString();
			}
		}
	}
	
	private void OnSendPressed()
	{
		Node network = (Node)GetTree().GetRoot().GetNode("Start").Get("network");
		TextEdit input = (TextEdit)GetNode("ChatContainer/Input");		
		network.Call("request_gui_sync", "chat", new Godot.Collections.Dictionary<string, object>(){
			["append"]="\n["+(string)((Node2D)network.Get("own_player")).Get("username")+"]: "+input.Text,
			["dead"]=(bool)((Node2D)network.Get("own_player")).Get("dead")
		});
	}
	
	private void OnFocusEntered()
	{
		originalMovement = GetMovement();
		SetMovement(false);
	}
	
	private void OnFocusExited()
	{
		SetMovement(originalMovement);
	}

	private void OnTextChanged()
	{
		TextEdit input = (TextEdit)GetNode("ChatContainer/Input");	
	   	if(input.Text.Length > 0){
			if(input.Text[input.Text.Length - 1] == '\n'){
				input.Text = input.Text.Trim(new char[]{'\n'});
				OnSendPressed();
				input.Text = "";
			}
		}
	}
}
