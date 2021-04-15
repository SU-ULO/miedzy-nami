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
		return !(bool)((Node2D)network.Get("own_player")).Get("disabled_movement");
	}
	
	public void show(bool state){
		this.Visible = state;
		
		if(state){
			GetNode("ChatContainer/Input").Call("grab_focus");
			GetNode("ChatContainer/Input").Set("readonly", !state);
			originalMovement = GetMovement();
			SetMovement(false);
		}
		else{
			GetNode("ChatContainer/Input").Call("release_focus");
			SetMovement(originalMovement);
		}
		
		Node GUI = GetParent().GetParent();
		GUI.Call("set_visibility", "PC", "CommunicationButtons/chat/new", 0);
	}
	
	void HandleGUISync(string guiName, Godot.Collections.Dictionary<string, object> data){
		Node network = (Node)GetTree().GetRoot().GetNode("Start").Get("network");
		Node2D player = ((Node2D)network.Get("own_player"));
		
		if(guiName.Equals("chat")){
			RichTextLabel chat = (RichTextLabel)GetNode("ChatContainer/Chat");
			if(data.ContainsKey("append")){
				if(data.ContainsKey("dead"))
					if((bool)data["dead"] && !(bool)player.Get("dead"))
						return;
				chat.Text += data["append"].ToString();
			}else if(data.ContainsKey("set")){
				chat.Text = data["set"].ToString();
			}
		}
		if(!this.Visible){
			Node GUI = GetParent().GetParent();
			GUI.Call("set_visibility", "PC", "CommunicationButtons/chat/new", 1);
		}
	}
	
	private void OnSendPressed()
	{
		Node network = (Node)GetTree().GetRoot().GetNode("Start").Get("network");
		TextEdit input = (TextEdit)GetNode("ChatContainer/Input");
		if(input.Text != ""){
			network.Call("request_gui_sync", "chat", new Godot.Collections.Dictionary<string, object>(){
			["append"]="\n["+(string)((Node2D)network.Get("own_player")).Get("username")+"]: "+input.Text,
			["dead"]=(bool)((Node2D)network.Get("own_player")).Get("dead")
			});
		}
		
		GetNode("ChatContainer/Input").Set("text", "");
		GetNode("ChatContainer/Input").Call("grab_focus");
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
