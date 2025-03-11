extends Node2D

#const OUTLINE_REF = [
	#"../Outlines/Outline5",
	#"../Outlines/Outline4",
	#"../Outlines/Outline3",
	#"../Outlines/Outline2",
	#"../Outlines/Outline1"
#]
const game_stage = ["pre", "flop", "turn", "river", "showdown"]
const ACTION_SCENE =  "res://Scene/action_label.tscn"

var actions = ["Call", "Fold", "Raise"]
var players_all = ["Player", "Opp"]
var players = []
var user_state = {}
var hand
var stakes = {}
var players_data = {}
var table_cards
#var turns
var timeout_timer
var big_blind
var small_blind
var player_count = 2
var dealer
#var player_turn
var stake = 25000
var game_manager_ref
var stake_label
var deck_ref
var player_ref
var opponent_ref 
var action_timer

func _ready() -> void:
	deck_ref = $"../Deck"
	game_manager_ref = $"../GameManager"
	player_ref = $"../Player"
	stake_label = $"../StakeLabel"
	opponent_ref = $"../OpponentHand"
	action_timer = $"../ActionTimer"
	dealer = players_all.pick_random()
	print(dealer)
	sort_by_turns()

func init():
	var player_data = []
	var card_count = 2
	
	for i in players:
		#testing putting player data into a single dictionary array
		player_data.append(stake) 
		player_data.append(false)
		
		#players_data[i] = player_data
		stakes[i] = stake
		user_state[i] = false
		
		hand = deck_ref.draw_card(card_count)
		player_data.append(hand)
		players_data[i] = player_data
		if i == "Player":
			player_ref.draw_card_image(players_data[i][2], $"../Player")
		elif i == "Opp" :
			opponent_ref.opponent_card_draw(players_data[i][2])
		player_data.clear()
	stake_label.text = str(stakes["Player"])

#func initial_draw():
	#var card_count = 2
	#stake_label.text = str(table_ref.stakes["Player"])
	
	#for i in table_ref.players:
		#table_ref.hands[i] = deck_ref.draw_card(card_count)
		#if i == "Player":
			#draw_card_image(table_ref.hands[i], $"../Player")
		#elif i == "Opp" :
			#opponent_card_draw(table_ref.hands[i])
	#
	#current_user = table_ref.players[0]
	#game_manager_ref.rotation()
	
#func draw_card_image(hand, node):
	#var card_scene = preload(CARD_SCENE)
	#for i in range(hand.size()):
		#var new_card = card_scene.instantiate()
		#var card_image_path = str("res://Assets/"+hand[i]+".png")
		#new_card.get_node("Card_Image").texture = load(card_image_path)
		#if node == $"../Player":
			#node.add_card_to_hand(new_card, i)
		#elif node == $"../Outlines":
			#node.add_child(new_card)
			#deck_ref.animate_card_to_position(new_card, OutlinePos[i])
		
#func opponent_card_draw(hand):
	#var opponent_card_scene = preload(OPPONENT_CARD_SCENE)
	#for i in range(hand.size()):
		#var opponent_card = opponent_card_scene.instantiate()
		#$"../OpponentHand".add_child(opponent_card)
		#$"../OpponentHand".update_hand_positions(opponent_card, i)


#add coodrinates for all players
func show_action_label(action):
	action_timer.one_shot = true
	action_timer.wait_time = 2.0
	
	var action_scene =  preload(ACTION_SCENE)
	var action_scene_label = action_scene.instantiate()
	$"../OpponentHand".add_child(action_scene_label)
	action_scene_label.text = action
	
	#Coodinates should be static in an array for easy access and limited players;
	#Create a seperate database for player data ?
	action_scene_label.position.x = $"../OpponentHand".center_screen_x
	action_scene_label.position.y = 260
	action_scene_label.visible = true
	
	action_timer.start()
	await action_timer.timeout
	action_scene_label.visible = false
	
	
func sort_by_turns():
	var dealer_index = players_all.find(dealer)
	if dealer_index == players_all.size()-1:
		for player in players_all:
			players.append(player)
	elif dealer_index != players_all.size()-1:
		for i in range(dealer_index+1, players_all.size()):
			players.append(players_all[i])
		for i in range(dealer_index+1):
			players.append(players_all[i])
	pass
	#if next_index >= players.size():
		#player_turn = players[0]
	#else :
		#player_turn = players[next_index]

func reset_user_state():
	for i in user_state:
		user_state[i] = false
		
