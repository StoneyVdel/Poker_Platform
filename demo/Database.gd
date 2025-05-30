extends Node

var user
var client_id
var leaderboard_ui

@rpc("any_peer", "call_remote", "reliable", 0)
func set_chips(chips:int, ses_id: int):
	pass

@rpc("any_peer", "call_remote", "reliable", 0)
func set_wins(chips:int, ses_id: int):
	pass

@rpc("any_peer", "call_remote", "reliable", 0)
func get_leaderboard(criteria:String):
	pass
	
@rpc("authority", "call_remote", "reliable", 0)
func return_leaderboard(leaderboard:Array):
	print(leaderboard_ui)
	leaderboard_ui = leaderboard
	
@rpc("any_peer", "call_remote", "reliable", 0)
func create_account(username: String, email: String, phone: String, password: String) -> bool:
	return true

@rpc("any_peer", "call_remote", "reliable", 0)
func update_account(username: String, email: String, phone: String, password: String) -> bool:
	return true
	
@rpc("any_peer", "call_remote", "reliable", 0)
func verify_login(email: String, password: String):
	pass
	
@rpc("authority", "call_remote", "reliable", 0)
func return_user_data(user_data: Dictionary):
	user = user_data
	
	print(user)
	
@rpc("authority", "call_remote", "reliable", 0)
func set_client_id(id: int):
	client_id=id
	print(client_id)
