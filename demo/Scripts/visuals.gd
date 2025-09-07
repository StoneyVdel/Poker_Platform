extends Node

const CARD_SCENE = "res://Scene/card.tscn"
const CARD_WIDTH = 124*1
const animation_time = 5
enum GameStage {
	pre,
	flop,
	turn,
	river,
	showdown
}

var stage = GameStage.pre
var coin_label
var raise_label
var total_bets_label
var action_scene_label
var card_rank_label
var action_timer
var deck_ref
var screen_size
var table_ref
var action_log
var chairs
var player_ref 
var chair_info_player
var label_info_player
var OutlinePos = []
var hand_eval_ref
var out_chance_label
var suggested_move_label
var chat_edit
var analytics
var analytics_allowed = true

func _ready() -> void:
	coin_label = $"../CoinLabel"
	raise_label = $"../BetControl/RaiseLabel"
	total_bets_label = $"../TotalBetLabel"
	action_timer = $"../ActionTimer"
	action_log = $"../Chat/ActionLog"
	player_ref = $"../Player"
	hand_eval_ref = $"../HandEvaluatorClient"
	chairs = $"../Chairs".get_children()
	card_rank_label = $"../Analytics/CardRank"
	out_chance_label = $"../Analytics/OutChance"
	suggested_move_label = $"../Analytics/SuggestedMove"
	chat_edit = $"../Chat/ChatEdit"
	analytics = $"../Analytics"
	
	screen_size = get_viewport().size
	
func animate_card_to_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.65)

@rpc("authority", "call_remote", "reliable", 0)
func are_analytics_allowed(allowed: bool):
	analytics_allowed=allowed

@rpc("authority", "call_remote", "reliable", 0)
func analytics_visible(on: bool):
	if analytics_allowed == true:
		analytics.visible = true
	else:
		analytics.propagate_call("set_visible", [false])
		analytics.visible = true
		var label = Label.new()
		label.add_theme_font_size_override("font_size", 18)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.text = "Analytics disabled by server!"
		analytics.add_child(label)
		await get_tree().create_timer(4).timeout
		analytics.remove_child(label)
		analytics.visible = false

func set_analytics(hand_rank, out_chance, move):
	card_rank_label.text = str("Current card rank: ", hand_eval_ref.hand_rank_to_string(hand_rank))
	out_chance_label.text = str("Chances to out: ", out_chance, "%")
	suggested_move_label.text = str("Suggested move: ", move)
	
@rpc("authority", "call_remote", "reliable", 0)
func draw_card_image(hand:Array, node:String):
	if node == "Outlines":
		for card in hand:
				player_ref.all_cards.append(card)
	var card_scene = load(CARD_SCENE)
	for i in range(hand.size()):
		var new_card = card_scene.instantiate()
		set_texture(hand[i], new_card)
		if node == "Player":
			new_card.add_to_group(str(player_ref.player_id,"cards"))
			add_card_to_hand(new_card, i, chair_info_player.find_key(player_ref.player_id))
		elif node == "Outlines":
			$"../Outlines".add_child(new_card)
			new_card.add_to_group("Outlines")
			new_card.process_mode = 4
			animate_card_to_position(new_card, OutlinePos[i])

func set_texture(card, object):
	var card_image_path = str("res://Assets/"+card+".png")
	object.get_node("Card_Image").texture = load(card_image_path)
	
@rpc("authority", "call_remote", "reliable", 0)
func add_card_to_hand(card, index, chair_id):
		$"../Player".add_child(card)
		update_hand_positions(card, index, chair_id)

@rpc("authority", "call_remote", "reliable", 0)
func cards_to_outline(game_stage: int):
	stage=game_stage
	if game_stage == GameStage.flop:
		OutlinePos.append($"../Outlines/Outline5".position)
		OutlinePos.append($"../Outlines/Outline4".position)
		OutlinePos.append($"../Outlines/Outline3".position)
		hand_eval_ref
			
	elif game_stage == GameStage.turn:
		OutlinePos.insert(0, $"../Outlines/Outline2".position)
		
	elif game_stage == GameStage.river:
		OutlinePos.insert(0, $"../Outlines/Outline1".position)
	pass
	
func update_hand_positions(card, index, chair_id):
	var new_position = Vector2(clamp(calculate_card_position(index, chair_id), 0, screen_size.x) , 
		clamp(chairs[chair_id].position.y - 100, 0, screen_size.y ))
	if chair_id == chair_info_player.find_key(player_ref.player_id):
		card.pos = {"last_position" : var_to_str(new_position)}
	animate_card_to_position(card, new_position)
	
func calculate_card_position(index, chair_id):
	var x_offset = chairs[chair_id].position.x + (CARD_WIDTH * index) - CARD_WIDTH / 2
	x_offset+=75
	return x_offset

@rpc("authority", "call_remote", "reliable", 0)
func set_label(label, text=""):
	if label == "total_bets_label":
		total_bets_label.text = str("Total bets: ", text)
	if label == "coin_label":
		coin_label.text = str(text)
	if label == "raise_label":
		raise_label.text = str(text)
		
@rpc("any_peer", "call_remote", "reliable", 0)
func update_action_log(action: String):
	action_log.text += str(action, "\n")

@rpc("authority", "call_remote", "reliable", 0)
func set_chair(chair_info : Dictionary, label_info : Dictionary):
	chair_info_player = chair_info
	label_info_player = label_info
	for id in chair_info:
		print("ID: ", id, " User: ", chair_info[id])
		chairs[id].get_node("Label").text = str(label_info[id])

@rpc("authority", "call_remote", "reliable", 0)
func clear_table():
	var nodes = get_tree().get_nodes_in_group("Outlines")
	free_node(nodes)
	var users = chair_info_player.values()
	for user in users:
		nodes = get_tree().get_nodes_in_group(str(user, "cards"))
		free_node(nodes)
	
@rpc("authority", "call_remote", "reliable", 0)
func win_state(state):
	if state == true:
		if ClientData.user_data.has("wins"):
			ClientData.user_data["wins"] +=1
		$"../CanvasLayer2/WinState".win()
	else :
		$"../CanvasLayer2/WinState".lose()
	player_ref.timeout_time+=animation_time
	action_timer.set_wait_time(animation_time)
	action_timer.start()
	await action_timer.timeout
	player_ref.timeout_time-=animation_time
	$"../CanvasLayer2/WinState".renew()
	#clear_table()

func free_node(nodes):
	for node in nodes:
			node.queue_free()

@rpc("authority", "call_remote", "reliable", 0)
func clear_chair(user):
	var nodes = get_tree().get_nodes_in_group(user)
	for node in nodes:
		node.find_child("Label").text= ""
	nodes = get_tree().get_nodes_in_group(str(user,"cards"))
	free_node(nodes)
	
func _on_send_btn_pressed() -> void:
	var text = str(label_info_player[chair_info_player.find_key(player_ref.player_id)], ":", chat_edit.text)
	chat_edit.text = ""
	update_action_log(text)
	update_action_log.rpc(text)
