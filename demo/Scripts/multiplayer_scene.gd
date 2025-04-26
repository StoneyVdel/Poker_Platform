extends Control

var game = preload("res://Scene/game.tscn")

func _on_join_game_pressed() -> void:
	var ip_addr = $VBoxContainer/IP_Address.text
	var port = $VBoxContainer/Port.text
	print("Joining game")
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip_addr, int(port))
	multiplayer.multiplayer_peer = peer
	get_tree().change_scene_to_packed(game)
	pass # Replace with function body.


func _on_host_game_pressed() -> void:
	pass # Replace with function body.
