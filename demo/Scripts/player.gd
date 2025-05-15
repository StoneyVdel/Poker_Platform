extends Node2D

var visuals_ref
var opponent_ref
var hand_eval_ref

var timeout_timer
var timeout_label
var current_raise = 0
var player_cards
var coins
var player_id 
var all_cards = []

var is_add_button_down = false
var is_subtract_button_down = false
var i = 0
var timeout_time = 20.0
var increase_amount
var raise_check_user
var last_bet_user
var min_value = 0

func _ready() -> void:
	visuals_ref = $"../Visuals"
	timeout_timer = $"../TimeoutTimer"
	opponent_ref = $"../Opponent"
	timeout_label = $"../TimeoutLabel"
	hand_eval_ref = $"../HandEvaluatorClient"
		
	timeout_timer.one_shot = true
	timeout_timer.wait_time = timeout_time
	timeout_timer.timeout.connect(_on_timer_timeout)

@rpc("authority","call_remote", "reliable", 0)
func add_players_to_table(user_id, chair_id):
	opponent_ref.opponent_card_draw(2, user_id, chair_id)
	pass
	
@rpc("authority", "call_remote", "reliable", 0)
func set_player_id(id: int):
	player_id=id
	print(player_id)
	
@rpc("authority", "call_remote", "unreliable", 0)
func set_increase_amount(amount):
	increase_amount = amount

@rpc("authority", "call_remote", "reliable", 0)
func init(player_cards: Array, coin:int, inc_ammount:int):
	all_cards.clear()
	print("Initializing")
	all_cards = player_cards.duplicate()
	#Getting card images for the player cards
	visuals_ref.draw_card_image(player_cards, "Player") 
	visuals_ref.raise_label.text = str(current_raise)
	coins = coin
	increase_amount = inc_ammount
	visuals_ref.set_label("coin_label", coins)

@rpc("authority", "call_remote", "reliable", 0)
func get_coins(player_id:int):
	pass
	
@rpc("authority", "call_remote", "reliable", 0)
func set_coins(coin:int):
	coins=coin
	visuals_ref.set_label("coin_label", coins)
	
@rpc("authority", "call_remote", "reliable", 0)
func user_turn(raise_check: bool, last_bet:int):
	$"../ActionControl/Call".disabled = false
	$"../ActionControl/Fold".disabled = false
	$"../ActionControl/Raise".disabled = false
	
	analytics_proc()
	
	raise_check_user = raise_check
	last_bet_user = last_bet
	timeout_timer.start()
	
func analytics_proc():
	var hand_rank = hand_eval_ref.evaluate_hand(all_cards)
	var out_chance = hand_eval_ref.out_chance(hand_rank, visuals_ref.stage)
	print("Hand rank: ", hand_rank)
	visuals_ref.set_analytics(hand_rank, out_chance)
	
func _on_timer_timeout() -> void:
	_on_fold_pressed()
	
func call_func(check_if_raise, last_bet):
	var action = "Check"
	if check_if_raise == true:
		action= "Call"
		get_coins.rpc_id(1, player_id)
		if last_bet > coins:
			#Send to backend
			user_raise.rpc_id(1, player_id, coins, "Call")
		else :
			#Send to backend
			user_raise.rpc_id(1, player_id, last_bet, "Call")
		get_coins.rpc_id(1, player_id)
		raise_check()
		visuals_ref.set_label("coin_label", coins)
	end_move(player_id, action)

func end_move(user_id: int, action: String):
	timeout_timer.wait_time = timeout_time
	analytics_proc()
	disable_user_input()
	timeout_timer.stop()
	server_end_move.rpc_id(1, user_id, action)

@rpc("authority", "call_remote", "reliable", 0)
func disable_user_input():
	$"../ActionControl/Call".disabled = true
	$"../ActionControl/Fold".disabled = true
	$"../ActionControl/Raise".disabled = true
	timeout_timer.stop()

@rpc("authority", "call_remote", "reliable", 0)
func server_end_move(user_id: int):
	pass
	
func check_raise_values(add):
	if add == true:
		if current_raise < coins:
			current_raise+= increase_amount
		else :
			pass
	if add == false:
		if min_value > 0:
			if current_raise > min_value:
				current_raise-= increase_amount
		elif current_raise > increase_amount:
			current_raise-= increase_amount
		
	visuals_ref.set_label("raise_label", str(current_raise))
	i=0

func raise_check():
	if current_raise > coins:
			while current_raise > coins:
				current_raise-= increase_amount
			visuals_ref.set_label("raise_label", str(current_raise))

@rpc("authority", "call_remote", "reliable", 0)
func folded(player_id:int):
	pass
	
func _process(_delta):
	timeout_label.text = str("%0.2f" % timeout_timer.time_left," s")
	if is_add_button_down:
		if i == 80:
			check_raise_values(true)
		i+=1
	if is_subtract_button_down:
		if i == 80:
			check_raise_values(false)
		i+=1
		
@rpc("any_peer", "call_remote", "reliable", 0)
func user_raise(user_id: int, raise: int):
	pass
	
@rpc("authority", "call_remote", "reliable", 0)
func set_raise(raise: int):
	current_raise = raise
	min_value = raise
	visuals_ref.set_label("raise_label", str(current_raise))
	
func _on_call_pressed() -> void:
	call_func(raise_check_user, last_bet_user)
	min_value = 0

func _on_fold_pressed() -> void:
	end_move(player_id, "Folded")
	folded.rpc_id(1, player_id)

func _on_raise_pressed() -> void:
	min_value = 0
	user_raise.rpc_id(1, player_id, current_raise, "Raise")
	raise_check()
	visuals_ref.set_label("coin_label", coins)
	end_move(player_id, "Raised")

func _on_add_pressed() -> void:
	check_raise_values(true)
	
func _on_subtract_pressed() -> void:
	check_raise_values(false)

func _on_timeout_timer_timeout() -> void:
	end_move(player_id, "Folded (Ran out of time)")
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
