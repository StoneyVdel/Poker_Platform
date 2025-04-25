extends Node

const CARD_SCENE = "res://Scene/card.tscn"

var current_user
var deck_ref
var table_ref
var player_ref
var temp_timer
var timer_label
var action_label
#var action_timer
var OutlinePos = []
var game_stage = "pre"
var timeout_time = 5
var hands_ref
var opponent_ref
var visuals_ref

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	deck_ref = $"../Deck"
	table_ref = $"../Table"
	player_ref = $"../Player"
	temp_timer = $"../TempTimer"
	temp_timer.one_shot = true
	timer_label = $"../TimerLabel"
	hands_ref = $"../Hands"
	opponent_ref = $"../OpponentHand"
	visuals_ref =  $"../Visuals"
	
	table_ref.init()
	player_ref.init()
	current_user = table_ref.players[0]
	rotation()

func user_turn():
	$"../ActionControl/Call".disabled = false
	$"../ActionControl/Fold".disabled = false
	$"../ActionControl/Raise".disabled = false
	
	player_ref.timeout_timer.wait_time = timeout_time
	#player_ref.timeout_timer.start()
	
func opponent_turn():
	temp_timer.wait_time = 2.0
	temp_timer.start()
	
	await temp_timer.timeout
	randomize()
	opponent_ref.actions.shuffle()
	var action = opponent_ref.actions[0]
	#action = "Fold"
	if action == "Raise":
		var raise_amount = randi_range(1, table_ref.players_data[current_user][0]-20)
		table_ref.table_bet(raise_amount, current_user, action)
		table_ref.reset_user_state()
		player_ref.end_move(current_user, action)
	elif action == "Call":
		#if table_ref.last_bet != null:
			#table_ref.table_bet(table_ref.last_bet, current_user, action)
		player_ref.end_move(current_user, action)
	elif action == "Fold" && table_ref.players.size() > 2:
		table_ref.players_state[current_user][2] = true
		player_ref.end_move(current_user, action)
	else: 
		action="Call"
		player_ref.end_move(current_user, action)
		
func rotation():
	var state_check = true
	check_if_remove()
	for i in table_ref.players_state:
		if table_ref.players_state[i][0] == false:
			state_check = false
			
	if state_check == true:
		var stage_index = table_ref.game_stage.find(game_stage)
		game_stage = table_ref.game_stage[stage_index+1]
		table_ref.reset_user_state()
		
		if game_stage == "flop":
			OutlinePos.append($"../Outlines/Outline5".position)
			OutlinePos.append($"../Outlines/Outline4".position)
			OutlinePos.append($"../Outlines/Outline3".position)
			table_draw(3)
			pass
			
		elif game_stage == "turn":
			OutlinePos.insert(0, $"../Outlines/Outline2".position)
			table_draw(1)
			
		elif game_stage == "river":
			OutlinePos.insert(0, $"../Outlines/Outline1".position)
			table_draw(1)
		
		elif game_stage == "showdown":
			table_ref.format_data()
			opponent_ref.show_opponent_hand()
			if table_ref.winners.find("Player") != -1:
				print("You win !")
				$"../CanvasLayer2/WinState".win()
				#table_ref.players_data["Player"][0] = (table_ref.get_bets("Player")+table_ref.table_bets)
			else :
				print("You lose !")
				$"../CanvasLayer2/WinState".lose()
				#table_ref.players_data["Opp"][0] =  (table_ref.get_bets("Opp")+table_ref.table_bets)

			table_ref.table_bets = 0
			visuals_ref.set_label(visuals_ref.total_bets_label, str(table_ref.table_bets))
			opponent_ref.show_opponent_hand()
			pass
	else : 
		if current_user == "Player" && player_ref.bet != 0:
			user_turn()
		elif current_user != "Player" && table_ref.get_bets(current_user) != 0 :
			opponent_turn()
		else:
			no_money()

func check_if_remove():
	for i in table_ref.players_state:
		if table_ref.players_state[i][2] == true:
			table_ref.clear_chair(i)

func no_money():
	var check_coins = 0
	for i in table_ref.players:
		if table_ref.get_bets(i) == 0:
			check_coins+=1
	if check_coins == table_ref.players.size():
		for i in table_ref.players_state:
			table_ref.players_state[i][0] = true
		game_stage=table_ref.game_stage[table_ref.game_stage.find(game_stage)+1]
		rotation()
		
func table_draw(card_count):
	var hand = deck_ref.draw_card(card_count)
	for i in hand:
		table_ref.table_cards.append(i)
	
	visuals_ref.draw_card_image(hand, $"../Outlines")
		
	rotation()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
