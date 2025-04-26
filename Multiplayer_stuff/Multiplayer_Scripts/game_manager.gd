extends Node

var current_user
var deck_ref
var table_ref
var temp_timer
#var action_timer
var OutlinePos = []
var game_stage = "pre"
var opponent_ref
var visuals_ref
var player_ref
var player_ids

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	deck_ref = $"../DeckLogic"
	table_ref = $"../GameLogic"
	temp_timer = $"../TempTimer"
	opponent_ref = $"../Opponent"
	visuals_ref = $"../Visuals"
	player_ref = $"../Player"
	temp_timer.one_shot = true

func start_game():
	table_ref.init()
	current_user = table_ref.players[0]
	rotation()
	
func  opponent_draw():
	for user in table_ref.players:
		if user != "Player":
			opponent_ref.opponent_card_draw(2, user, table_ref.players.find(user))
				
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
			#To_Client
			opponent_ref.get_playersdata2()
			opponent_ref.show_opponent_hand()
			table_ref.table_bets = 0
			
			pass
	else : 
		if table_ref.players_data[current_user][0] != 0:
			player_ref.user_turn().rpc_id()
		else:
			no_money()

func check_if_remove():
	for i in table_ref.players_state:
		if table_ref.players_state[i][2] == true:
			visuals_ref.clear_chair(i)

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


func find_next_user(user):
	var next_user_index = table_ref.players.find(user)+1
	var next_user
	if next_user_index < table_ref.players.size():
		next_user = table_ref.players[next_user_index]
	else :
		next_user = table_ref.players[0]
	return next_user
