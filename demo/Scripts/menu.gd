extends Control

@export var LoginWindow: PackedScene
@export var CreateAccountWindow : PackedScene
@export var OptionsScene : PackedScene

var login_window
var update_window
var chips = 100
var coins_label 

func _ready() -> void:
	coins_label = $MarginContainer2/VBoxContainer/Coins
	var ip_addr = "127.0.0.1"
	var port = 8015
	print("Joining game")
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip_addr, int(port))
	multiplayer.multiplayer_peer = peer
	
	if ClientData.user_data.has("username") && ClientData.user_data.has("password"): 
		await get_tree().create_timer(2).timeout
		Database.verify_login.rpc_id(1, ClientData.user_data["username"], ClientData.hash_data(ClientData.user_data["password"]))
		set_account_btn()
		coins_label.text = str(ClientData.user_data["chips"])
		Database.set_chips.rpc_id(1, ClientData.user_data["chips"])
		Database.set_wins.rpc_id(1, ClientData.user_data["wins"])
	else:
		$MarginContainer2/VBoxContainer/Coins.text = str(chips)
	await get_tree().create_timer(1).timeout
	Database.get_leaderboard.rpc_id(1, "wins")
	await get_tree().create_timer(1).timeout
	set_leaderboard()

func set_leaderboard():
	var leaderboard_ui = $Panel
	leaderboard_ui.clear()
	if Database.leaderboard_ui != null:
		for player in Database.leaderboard_ui:
			print(player["username"])
			leaderboard_ui.add_entry(player["username"], player["wins"], player["chips"])
	else:
		leaderboard_ui.error_entry()
		
func _on_play_pressed() -> void:
	multiplayer.multiplayer_peer.disconnect_peer(1) 
	get_tree().change_scene_to_file("res://Scene/multiplayer_menu_scene.tscn")


func _on_options_pressed() -> void:
	var Options = OptionsScene.instantiate()
	add_child(Options)


func _on_quit_pressed() -> void:
	get_tree().quit()

func set_account_btn():
	$MarginContainer2/VBoxContainer/User.text = ClientData.user_data["username"]
	
func _on_login_pressed() -> void:
	if ClientData.login_success == false:
		login_window = LoginWindow.instantiate()
		add_child(login_window)
	else:
		update_window = CreateAccountWindow.instantiate()
		add_child(update_window)


func _on_by_wins_pressed() -> void:
	Database.get_leaderboard.rpc_id(1, "wins")
	await get_tree().create_timer(1).timeout
	set_leaderboard()

func _on_by_chips_pressed() -> void:
	Database.get_leaderboard.rpc_id(1, "chips")
	await get_tree().create_timer(1).timeout
	set_leaderboard()
