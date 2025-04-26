extends Node

const CARD_SCENE = "res://Scene/card.tscn"
const CARD_WIDTH = 124*1

var coin_label
var raise_label
var total_bets_label
var action_scene_label
var action_timer
var deck_ref
var screen_size
var table_ref
var action_log
var chairs
var player_ref 
var chair_info_player
var OutlinePos = []

func _ready() -> void:
	coin_label = $"../CoinLabel"
	raise_label = $"../BetControl/RaiseLabel"
	total_bets_label = $"../TotalBetLabel"
	action_timer = $"../ActionTimer"
	action_log = $"../ActionLog"
	player_ref = $"../Player"
	chairs = $"../Chairs".get_children()
	screen_size = get_viewport().size
	
func animate_card_to_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.65)

@rpc("authority", "call_remote", "reliable", 0)
func draw_card_image(hand:Array, node:String):
	print(hand, node)
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
			animate_card_to_position(new_card, OutlinePos[i])

func set_texture(card, object):
	var card_image_path = str("res://Assets/"+card+".png")
	object.get_node("Card_Image").texture = load(card_image_path)
	
@rpc("authority", "call_remote", "reliable", 0)
func add_card_to_hand(card, index, chair_id):
		$"../Player".add_child(card)
		update_hand_positions(card, index, chair_id)

@rpc("authority", "call_remote", "reliable", 0)
func cards_to_outline(game_stage: String):
	if game_stage == "flop":
		OutlinePos.append($"../Outlines/Outline5".position)
		OutlinePos.append($"../Outlines/Outline4".position)
		OutlinePos.append($"../Outlines/Outline3".position)
			
	elif game_stage == "turn":
		OutlinePos.insert(0, $"../Outlines/Outline2".position)
		
	elif game_stage == "river":
		OutlinePos.insert(0, $"../Outlines/Outline1".position)
	pass
	
func update_hand_positions(card, index, chair_id):
	var new_position = Vector2(clamp(calculate_card_position(index, chair_id), 0, screen_size.x) , 
		clamp(chairs[chair_id].position.y - 100, 0, screen_size.y ))
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
		
@rpc("authority", "call_remote", "reliable", 0)
func update_action_log(action: String):
	action_log.text += str(action, "\n")

@rpc("authority", "call_remote", "reliable", 0)
func set_chair(chair_info : Dictionary):
	chair_info_player = chair_info
	for id in chair_info:
		print("ID:", id, "User:", chair_info[id])
		chairs[id].get_node("Label").text = str(chair_info[id])

@rpc("authority", "call_remote", "reliable", 0)
func win_state(state):
	if state == 1:
		print("You win !")
		$"../CanvasLayer2/WinState".win()
	else :
		print("You lose !")
		$"../CanvasLayer2/WinState".lose()
	
	action_timer.set_wait_time(5)
	action_timer.start()
	await action_timer.timeout
	$"../CanvasLayer2/WinState".renew()
	var nodes = get_tree().get_nodes_in_group("Outlines")
	free_node(nodes)
	var users = chair_info_player.values()
	for user in users:
		nodes = get_tree().get_nodes_in_group(str(user, "cards"))
		free_node(nodes)
	OutlinePos.clear()
	pass
	#set_label("total_bets_label", str(table_ref.table_bets))

func free_node(nodes):
	for node in nodes:
			node.queue_free()
			
@rpc("authority", "call_remote", "reliable", 0)
func clear_chair(user):
	#var user_index = players.find(user)
	#var next_user = player_ref.find_next_user(user)
	var nodes = get_tree().get_nodes_in_group(user)
	for node in nodes:
		node.queue_free()
	nodes = get_tree().get_nodes_in_group(str(user,"cards"))
	for node in nodes:
		node.queue_free()
