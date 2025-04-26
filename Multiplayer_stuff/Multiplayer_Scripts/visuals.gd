extends Node

var action_scene_label
var action_timer
var table_ref
var action_log

func _ready() -> void:
	action_log = $"../ActionLog"
	table_ref = $"../GameLogic"
	
func action_label_action(action):
	action_scene_label.text = action
	action_scene_label.visible = true
	
	action_timer.start()
	await action_timer.timeout
	action_scene_label.visible = false

@rpc("any_peer", "call_remote", "reliable")
func draw_card_image(hand: Array[String], node: String):
	pass

@rpc("any_peer", "call_remote", "reliable")
func add_card_to_hand(card: String, index: int, chair_id: int):
		pass

@rpc("any_peer", "call_remote", "reliable")
func set_label(label: String, text: String):
	pass
		
@rpc("any_peer", "call_remote", "reliable")
func update_action_log(action: String):
	pass
	#action_log.text += str(action, "\n")

@rpc("any_peer", "call_remote", "reliable")
func set_chair(chair_id: int, user_id: int):
	pass

@rpc("any_peer", "call_remote", "reliable")
func win_state(state: bool):
	pass
	#opponent_ref.show_opponent_hand()

@rpc("any_peer", "call_remote", "reliable", 0)
func clear_chair(user: String):
	table_ref.players.erase(user)
	table_ref.player_data.erase(user)
