extends Node

const CARD_SCENE = "res://Scene/card.tscn"
#const OPPONENT_CARD_SCENE = "res://Scene/opponent_card.tscn"
#const ACTION_SCENE =  "res://Scene/action_label.tscn"

var current_turn = 0
var current_user
var deck_ref
var table_ref
var player_ref
var timeout_timer
var temp_timer
var timer_label
var action_label
#var action_timer
var stake_label
var OutlinePos = []
var game_stage = "pre"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	deck_ref = $"../Deck"
	table_ref = $"../Table"
	player_ref = $"../Player"
	temp_timer = $"../TempTimer"
	temp_timer.one_shot = true
	timeout_timer = $"../TimeoutTimer"
	timeout_timer.one_shot = true 
	timer_label = $"../TimerLabel"
	#action_timer = $"../ActionTimer"
	
	table_ref.init()
	current_user = table_ref.players[0]
	rotation()
	
#func initial_draw():
	#var card_count = 2
	#stake_label.text = str(table_ref.stakes["Player"])
	#
	#for i in table_ref.players:
		#table_ref.hands[i] = deck_ref.draw_card(card_count)
		#if i == "Player":
			#draw_card_image(table_ref.hands[i], $"../Player")
		#elif i == "Opp" :
			#opponent_card_draw(table_ref.hands[i])
	#
	#current_user = table_ref.players[0]
	#rotation()
	#
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
		#
#func opponent_card_draw(hand):
	#var opponent_card_scene = preload(OPPONENT_CARD_SCENE)
	#for i in range(hand.size()):
		#var opponent_card = opponent_card_scene.instantiate()
		#$"../OpponentHand".add_child(opponent_card)
		#$"../OpponentHand".update_hand_positions(opponent_card, i)
#
##add coodrinates for all players
#func show_action_label(action):
	#action_timer.one_shot = true
	#action_timer.wait_time = 2.0
	#
	#var action_scene =  preload(ACTION_SCENE)
	#var action_scene_label = action_scene.instantiate()
	#$"../OpponentHand".add_child(action_scene_label)
	#action_scene_label.text = action
	#
	##Coodinates should be static in an array for easy access and limited players;
	##Create a seperate database for player data ?
	#action_scene_label.position.x = $"../OpponentHand".center_screen_x
	#action_scene_label.position.y = 260
	#action_scene_label.visible = true
	#
	#action_timer.start()
	#await action_timer.timeout
	#action_scene_label.visible = false
	#
func user_turn():
	$"../Call".disabled = false
	$"../Fold".disabled = false
	$"../Raise".disabled = false
	
	timeout_timer.wait_time = 10
	timeout_timer.start()
	
	if timeout_timer.time_left == 0:
		end_move()
		_on_fold_pressed()
		
func opponent_turn():
	temp_timer.wait_time = 3.0
	temp_timer.start()
	
	await temp_timer.timeout
	randomize()
	table_ref.actions.shuffle()
	var action = table_ref.actions[0]
	table_ref.show_action_label(action)
	end_move()
	rotation()
	
func end_move():
	$"../Call".disabled = true
	$"../Fold".disabled = true
	$"../Raise".disabled = true
	
	table_ref.user_state[current_user] = true
	var next_user_index = table_ref.players.find(current_user)+1
	if next_user_index < table_ref.players.size():
		current_user = table_ref.players[next_user_index]
	else :
		current_user = table_ref.players[0]
		
func rotation():
	
	if current_user == table_ref.players[0] && table_ref.user_state[current_user] == true:
		var stage_index = table_ref.game_stage.find(game_stage)
		game_stage = table_ref.game_stage[stage_index+1]
		table_ref.reset_user_state()
		
		if game_stage == "flop":
			flop()
		elif game_stage == "turn":
			rotation()
			pass
		elif game_stage == "river":
			#table_ref.game_stage
			pass
		elif game_stage == "showdown":
			#table_ref.game_stage
			pass
			
	else : 
		if current_user == "Player":
			user_turn()
		else :
			opponent_turn()
	
func flop():
	pass
	var card_count = 3
	
	OutlinePos.append($"../Outlines/Outline5".position)
	OutlinePos.append($"../Outlines/Outline4".position)
	OutlinePos.append($"../Outlines/Outline3".position)
	
	table_ref.table_cards = deck_ref.draw_card(card_count)
	
	for i in range(card_count):
		player_ref.draw_card_image(table_ref.table_cards, $"../Outlines")
	
	rotation()
	
func raise():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if table_ref.players.size() == 1:
		print("game over")
		#get_tree().quit()

func _on_call_pressed() -> void:
	end_move()
	timeout_timer.stop()
	rotation()


func _on_fold_pressed() -> void:
	end_move()
	table_ref.players.erase("Player")


func _on_raise_pressed() -> void:
	end_move()
	rotation()
	pass # Replace with function body.
