extends Node2D

const OPPONENT_CARD_SCENE = "res://Scene/opponent_card.tscn"

var deck_ref
var table_ref
var game_manager_ref
var visuals_ref

var timeout_timer
var current_raise
var player_cards
var bet
var is_add_button_down = false
var is_subtract_button_down = false
var i = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	deck_ref = $"../Deck"
	table_ref = $"../Table"
	game_manager_ref = $"../GameManager"
	visuals_ref = $"../Visuals"
	current_raise = table_ref.increase_amount
	timeout_timer = $"../TimeoutTimer"
	timeout_timer.one_shot = true

func init():
	player_cards = table_ref.get_cards("Player")
	bet = table_ref.get_bets("Player")
	
	#Getting card images for the player cards
	visuals_ref.draw_card_image(player_cards, $".")
	
	for user in table_ref.players:
		if user != "Player":
			$"../OpponentHand".opponent_card_draw(2, user)

	visuals_ref.raise_label.text = str(current_raise)
	visuals_ref.set_label(visuals_ref.coin_label)
	#Showing the betting coins of the player
	#stake_label_set_text(bet)

func call_func():
	timeout_timer.stop()
	if table_ref.players_state[game_manager_ref.current_user][1] == true:
		bet = table_ref.get_bets("Player")
		if table_ref.last_bet > bet:
			table_ref.table_bet(bet, game_manager_ref.current_user, "Call")
		else :
			table_ref.table_bet(table_ref.last_bet, game_manager_ref.current_user, "Call")
		bet = table_ref.get_bets("Player")
		raise_check()
		visuals_ref.set_label(visuals_ref.coin_label)
	end_move(game_manager_ref.current_user, "Call")
	
func end_move(user, action):
	$"../ActionControl/Call".disabled = true
	$"../ActionControl/Fold".disabled = true
	$"../ActionControl/Raise".disabled = true
	
	table_ref.players_state[user][0] = true
	visuals_ref.update_action_log(user+" "+action)
	game_manager_ref.current_user = find_next_user(user)
	
	game_manager_ref.rotation()

func find_next_user(user):
	var next_user_index = table_ref.players.find(user)+1
	var next_user
	if next_user_index < table_ref.players.size():
		next_user = table_ref.players[next_user_index]
	else :
		next_user = table_ref.players[0]
	return next_user
	
func check_raise_values(add):
	if add == true:
		if current_raise < bet:
			current_raise+=table_ref.increase_amount
		else :
			pass
	if add == false:
		if table_ref.players_state[game_manager_ref.current_user][1] == true:
			if current_raise > table_ref.last_bet:
				current_raise-= table_ref.increase_amount
		elif current_raise > table_ref.increase_amount:
			current_raise-= table_ref.increase_amount
		
	visuals_ref.set_label(visuals_ref.raise_label, str(current_raise))
	i=0

func raise_check():
	if current_raise > bet:
			while current_raise > bet:
				current_raise-= table_ref.increase_amount
			visuals_ref.set_label(visuals_ref.raise_label, str(current_raise))
	
func _process(_delta):
	if is_add_button_down:
		if i == 80:
			check_raise_values(true)
		i+=1
	if is_subtract_button_down:
		if i == 80:
			check_raise_values(false)
		i+=1

func _on_call_pressed() -> void:
	call_func()

func _on_fold_pressed() -> void:
	end_move(game_manager_ref.current_user, "Fold")
	table_ref.players_state[table_ref.players.find("Player")][2] = true
	get_tree().pause()
	get_tree().change_scene_to_file("res://Scene/menu.tscn")
	timeout_timer.stop()

func _on_raise_pressed() -> void:
	timeout_timer.stop()
	table_ref.table_bet(current_raise, game_manager_ref.current_user, "Raise")
	bet = table_ref.get_bets("Player")
	table_ref.reset_user_state()
	raise_check()
	#DRY
	visuals_ref.set_label(visuals_ref.coin_label)
	end_move(game_manager_ref.current_user,"Raise")

func _on_add_pressed() -> void:
	check_raise_values(true)
	
func _on_subtract_pressed() -> void:
	check_raise_values(false)

func _on_timeout_timer_timeout() -> void:
	end_move(game_manager_ref.current_user, "Fold")
	_on_fold_pressed()


func _on_add_button_down() -> void:
	is_add_button_down=true


func _on_add_button_up() -> void:
	is_add_button_down=false
	i=0


func _on_subtract_button_down() -> void:
	is_subtract_button_down=true


func _on_subtract_button_up() -> void:
	is_subtract_button_down=false
	i=0
