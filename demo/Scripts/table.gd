extends Node2D

const game_stage = ["pre", "flop", "turn", "river", "showdown"]
const ACTION_SCENE =  "res://Scene/action_label.tscn"

var actions = ["Call", "Fold", "Raise"]
var players_all = ["Player", "Opp"]
var players = []
#players_data = { User: [stake, card_names, #[card_values]] }
var players_data = {}
#players_state = { User: [user_state, needs_to_raise] }
var players_state = {}
var table_cards= []
var timeout_timer
var big_blind
var small_blind
var player_count = 2
var dealer
var game_manager_ref
var deck_ref
var player_ref
var opponent_ref
var action_timer
var stake = 100
var increase_amount = 1
var table_bets = 0
var last_bet
var hand_node
var room_name = "Test Room"
var reform_player_cards = []
var reform_table_cards
var room_node
var player_rank 
var opp_rank
var player_rank_name
var opp_rank_name
	
func _ready() -> void:
	deck_ref = $"../Deck"
	game_manager_ref = $"../GameManager"
	player_ref = $"../Player"
	opponent_ref = $"../OpponentHand"
	action_timer = $"../ActionTimer"
	dealer = players_all.pick_random()
	var hand_handler = load("res://Scripts/Program.cs")
	var room_handler = load("res://Scripts/Room.cs")
	var user_handler = load("res://Scripts/ApplicationUser.cs")
	room_node = room_handler.new()
	user_handler.new()
	hand_node = hand_handler.new()
	print(dealer)
	sort_by_turns()

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

#Initiating game: dealing cards
func init():
	var card_count = 2
	var hand
	
	for i in players:
		#creating a array for the player data
		players_data[i] = []
		players_state[i] = []
		players_data[i].insert(0, stake)
		players_state[i].insert(0, false)
		#Drawing cards for the players
		hand = deck_ref.draw_card(card_count)
		players_data[i].insert(1, hand)
		players_state[i].insert(1, false)

#add coodrinates for all players
#Shows the action taken as a short duration label
func show_action_label(action):
	action_timer.one_shot = true
	action_timer.wait_time = 1.0
	
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

#Resets players state for the next game stage
func reset_user_state():
	for i in players_data:
		players_state[i][0] = false
		
func table_bet(raise, user, action):
	table_bets+=raise
	players_data[user][0]-= raise
	if action == "Raise":
		last_bet = raise
		player_ref.current_raise = last_bet
		player_ref.raise_label.text = str(player_ref.current_raise)
	
		for i in players_state:
			if i != user:
				players_state[i][1] = true
				player_ref.current_raise = last_bet
	players_state[user][1] = false

	$TableBet.text = str(table_bets)
	
func format_data():
	reform_table_cards= deck_ref.reformat_cards(table_cards, "Table")
	for i in players_data:
		players_data[i].insert(2, deck_ref.reformat_cards(players_data[i][1], i))

	hand_node.TestProgram()
	
	player_rank = hand_node.U1rank
	opp_rank = hand_node.U2rank
	player_rank_name = hand_node.U1rankName
	opp_rank_name = hand_node.U2rankName
	
	pass
	
func win_state():
	pass

func get_cards(player):
	return players_data[player][1]
	
func get_bets(player):
	return players_data[player][0]
