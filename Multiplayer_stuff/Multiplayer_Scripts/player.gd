extends Node2D

var deck_ref
var table_ref
var game_manager_ref
var visuals_ref
var opponent_ref

var timeout_timer
var current_raise
var player_cards
@export var coins : int
@export var player_id : int
var increase_amount

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visuals_ref = $"../Visuals"
	#Fix
	current_raise =  1 #table_ref.increase_amount
	timeout_timer = $"../TimeoutTimer"
	opponent_ref = $"../Opponent"
	table_ref = $"../GameLogic"
	coins = 100
	increase_amount = table_ref.increase_amount
	
@rpc("authority","call_remote", "reliable", 0)
func add_players_to_table(user_id, chair_id):
	opponent_ref.opponent_card_draw(2, user_id, chair_id)
	pass
	
@rpc("authority", "call_remote", "reliable", 0)
func set_player_id(id: int):
	player_id=id

@rpc("any_peer", "call_remote", "reliable")
func init(player_cards):
	print("Initializing")
	
	#Getting card images for the player cards
	visuals_ref.draw_card_image(player_cards, $".")
	visuals_ref.raise_label.text = str(current_raise)
	visuals_ref.set_label(visuals_ref.coin_label, coins)

@rpc("authority", "call_remote", "unreliable", 0)
func user_turn():
	pass

@rpc("authority", "call_remote", "reliable", 0)
func set_increase_amount(increase_amount):
	pass
	
@rpc("authority", "call_remote", "unreliable", 0)
func call_func(check_if_raise, last_bet):
	timeout_timer.stop()
	if check_if_raise == true:
		coins = table_ref.get_bets("Player")
		if last_bet > coins:
			#Send to backend
			table_ref.table_bet(coins, game_manager_ref.current_user, "Call")
		else :
			#Send to backend
			table_ref.table_bet(table_ref.last_bet, game_manager_ref.current_user, "Call")
		coins = table_ref.get_bets("Player")
		raise_check()
		visuals_ref.set_label(visuals_ref.coin_label, coins)
	end_move()

@rpc("authority", "call_remote", "unreliable", 0)
func end_move():
	
	table_ref.players_state[game_manager_ref.current_user][0] = true
	game_manager_ref.current_user = game_manager_ref.find_next_user(player_id)
	
	game_manager_ref.rotation()

func raise_check():
	if current_raise > coins:
			while current_raise > coins:
				current_raise-= table_ref.increase_amount
			visuals_ref.set_label(visuals_ref.raise_label, str(current_raise))
	
