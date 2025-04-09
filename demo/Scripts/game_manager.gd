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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	deck_ref = $"../Deck"
	table_ref = $"../Table"
	player_ref = $"../Player"
	temp_timer = $"../TempTimer"
	temp_timer.one_shot = true
	timer_label = $"../TimerLabel"
	hands_ref = $"../Hands"
	
	table_ref.init()
	player_ref.init()
	current_user = table_ref.players[0]
	rotation()

func user_turn():
	$"../Call".disabled = false
	$"../Fold".disabled = false
	$"../Raise".disabled = false
	
	player_ref.timeout_timer.wait_time = timeout_time
	#player_ref.timeout_timer.start()
	
func opponent_turn():
	temp_timer.wait_time = 3.0
	temp_timer.start()
	
	await temp_timer.timeout
	randomize()
	#table_ref.actions.shuffle()
	#var action = table_ref.actions[0]
	var action = "Raise"
	if action == "Raise":
		var raise_amount = randi_range(1, table_ref.players_data[current_user][0]-20)
		table_ref.table_bet(raise_amount, current_user, action)
		table_ref.show_action_label(action+" "+str(raise_amount))
		table_ref.reset_user_state()
		player_ref.end_move()
	#else:
		#player_ref.end_move()
		#table_ref.show_action_label(action)
		
		
func rotation():
	var state_check = true
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
#			hands_ref.check_rank(player_ref.player_cards)
			pass
			
		elif game_stage == "turn":
			#change this into something smarter
			OutlinePos.insert(0, $"../Outlines/Outline2".position)
			table_draw(1)
		elif game_stage == "river":
			OutlinePos.insert(0, $"../Outlines/Outline1".position)
			table_draw(1)
			table_ref.format_data()
			if table_ref.player_rank > table_ref.opp_rank:
				print("You win !")
				table_ref.players_data["Player"].insert(0, table_ref.get_bets("Player")+table_ref.table_bets)
				player_ref.stake_label_set_text(table_ref.get_bets("Player"))
				table_ref.table_bets = 0
				player_ref.table_bet_label.text = str(table_ref.table_bets)
			else :
				print("You lose !")
				table_ref.players_data["Opp"].insert(0, table_ref.players_data["Opp"][0]+table_ref.table_bets)
				
				table_ref.table_bets = 0
				player_ref.table_bet_label.text = str(table_ref.table_bets)
			pass
		
	else : 
		if current_user == "Player":
			user_turn()
		else :
			opponent_turn()
	
func table_draw(card_count):
	var hand = deck_ref.draw_card(card_count)
	for i in hand:
		table_ref.table_cards.append(i)
	
	player_ref.draw_card_image(hand, $"../Outlines")
		
	rotation()
	
func game_lost():
	table_ref.players.erase("Player")
	get_tree().quit()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
