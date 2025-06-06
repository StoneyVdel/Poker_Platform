extends Node

const game_stage = ["pre", "flop", "turn", "river", "showdown"]

var players_all = ["Player"]
var players = []
var players_data = {}
#players_data = { User: [int stake, card_names[string], #card_values[string], int player_pot] }
var players_state = {}
#players_state = { User: [user_state, needs_to_raise] }
var table_cards= []
var big_blind #TB
var small_blind #TB
var dealer
var game_manager_ref
var deck_ref
var coins = 100
var increase_amount = 1
var table_bets = 0
var last_bet
var hand_node
var room_name = "Test Room"
var reform_player_cards = []
var reform_table_cards
var room_node
var winners
var player_ref
var visuals_ref

func _ready() -> void:
	deck_ref = $"../DeckLogic"
	game_manager_ref = $"../GameManager"
	player_ref = $Player
	hand_node= load("res://Scripts/Multiplayer/Program.cs").new()
	room_node = load("res://Scripts/Multiplayer/Room.cs").new()
	var _user_handler = load("res://Scripts/Multiplayer/ApplicationUser.cs").new()
	visuals_ref = $Visuals
	
func start_game():
	dealer = players_all.pick_random()
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
	#var j = 0
	
	for i in players:
		#creating a array for the player data
		players_data[i] = []
		players_state[i] = []
		players_data[i].insert(0, coins)
		players_data[i].insert(1, 0)
		players_state[i].insert(0, false)
		#Drawing cards for the players
		hand = deck_ref.draw_card(card_count)
		player_ref.init(hand)
		players_data[i].insert(2, hand)
		players_state[i].insert(1, false)
		players_state[i].insert(2, false)
		#deck_ref.chairs[j].get_node("Label").text = str(i)
		#j+=1

#Resets players state for the next game stage
func reset_user_state():
	for i in players_data:
		players_state[i][0] = false
		
func table_bet(raise, user, action):
	table_bets+=raise
	players_data[user][1] += raise
	players_data[user][0]-= raise
	if action == "Raise":
		last_bet = raise
		#Send to client
		player_ref.current_raise = last_bet
		visuals_ref.set_label(visuals_ref.raise_label, str(player_ref.current_raise))
		player_ref.raise_label.text = str(player_ref.current_raise)
	
		for i in players_state:
			if i != user:
				players_state[i][1] = true
	
	players_state[user][1] = false
	#visuals_ref.set_label(visuals_ref.total_bets_label, table_bets)
	
func format_data():
	reform_table_cards= deck_ref.reformat_cards(table_cards, "Table")
	for i in players_data:
		players_data[i].insert(3, deck_ref.reformat_cards(players_data[i][2], i))
	
	$"../JSON".to_json(players_data)
	
	hand_node.GetDataFromJSON($"../JSON".json_string)
	hand_node.TestProgram()
	print(hand_node.WinnerNames)
	winners = hand_node.WinnerNames
	pass
	
func get_cards(player):
	return players_data[player][2]
	
func get_bets(player):
	return players_data[player][0]
