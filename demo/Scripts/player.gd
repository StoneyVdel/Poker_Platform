extends Node2D

const CARD_SCENE = "res://Scene/card.tscn"
const OPPONENT_CARD_SCENE = "res://Scene/opponent_card.tscn"

const CARD_WIDTH = 124*1.36
var center_screen_x
var screen_size
var deck_ref
var table_ref
var game_manager_ref
var stake_label
var raise_label
var timeout_timer
var current_raise
var player_cards
var bet

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	deck_ref = $"../Deck"
	table_ref = $"../Table"
	center_screen_x = get_viewport().size.x / 2
	screen_size = get_viewport().size
	game_manager_ref = $"../GameManager"
	stake_label = $"../StakeLabel"
	raise_label = $"../RaiseLabel"
	current_raise = table_ref.increase_amount
	raise_label.text = str(current_raise)
	timeout_timer = $"../TimeoutTimer"
	timeout_timer.one_shot = true

func init():
	player_cards = table_ref.get_cards("Player")
	bet = table_ref.get_bets("Player")
	#Getting card images for the player cards
	draw_card_image(player_cards, $".")
	$"../OpponentHand".opponent_card_draw(2)
	#Showing the betting coins of the player
	stake_label.text = str(bet)
		
func draw_card_image(hand, node):
	var card_scene = preload(CARD_SCENE)
	for i in range(hand.size()):
		var new_card = card_scene.instantiate()
		var card_image_path = str("res://Assets/"+hand[i]+".png")
		new_card.get_node("Card_Image").texture = load(card_image_path)
		if node == $"../Player":
			node.add_card_to_hand(new_card, i)
		elif node == $"../Outlines":
			node.add_child(new_card)
			deck_ref.animate_card_to_position(new_card, game_manager_ref.OutlinePos[i])
			
func add_card_to_hand(card, index):
		$"../Player".add_child(card)
		update_hand_positions(card, index)
		
func update_hand_positions(card, index):
	var new_position = Vector2(clamp(calculate_card_position(index), 0, screen_size.x) , 
		clamp(screen_size.y - 130, 0, screen_size.y ))
	deck_ref.animate_card_to_position(card, new_position)
		
func calculate_card_position(index):
	var x_offset = center_screen_x + (CARD_WIDTH * index) - CARD_WIDTH / 2
	return x_offset

func call_func():
	timeout_timer.stop()
	if table_ref.players_state[game_manager_ref.current_user][1] == true:
		table_ref.table_bet(table_ref.last_bet, game_manager_ref.current_user, "Call")
		bet = table_ref.get_bets("Player")
		raise_checking()
		stake_label.text = str(bet)
	end_move()
	
func end_move():
	$"../Call".disabled = true
	$"../Fold".disabled = true
	$"../Raise".disabled = true
	
	table_ref.players_state[game_manager_ref.current_user][0] = true
		
	var next_user_index = table_ref.players.find(game_manager_ref.current_user)+1
	if next_user_index < table_ref.players.size():
		game_manager_ref.current_user = table_ref.players[next_user_index]
	else :
		game_manager_ref.current_user = table_ref.players[0]
		
	game_manager_ref.rotation()
	
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
		
	raise_label.text = str(current_raise)

func raise_checking():
	if current_raise > bet:
			while current_raise > bet:
				current_raise-= table_ref.increase_amount
			raise_label.text = str(current_raise)
	
func _on_call_pressed() -> void:
	call_func()

func _on_fold_pressed() -> void:
	end_move()
	timeout_timer.stop()
	game_manager_ref.game_lost()

func _on_raise_pressed() -> void:
	timeout_timer.stop()
	table_ref.table_bet(current_raise, game_manager_ref.current_user, "Raise")
	bet = table_ref.get_bets("Player")
	table_ref.reset_user_state()
	raise_checking()
	#DRY
	stake_label.text = str(bet)
	end_move()

func _on_subtract_pressed() -> void:
	check_raise_values(false)

func _on_add_pressed() -> void:
	check_raise_values(true)

func _on_timeout_timer_timeout() -> void:
	end_move()
	_on_fold_pressed()
