extends Node

const CARD_SCENE = "res://Scene/card.tscn"
const CARD_WIDTH = 124*1

var coin_label
var raise_label
var total_bets_label
var action_scene_label
var action_timer
var game_manager_ref
var deck_ref
var screen_size
var table_ref
var action_log

func _ready() -> void:
	coin_label = $"../CoinLabel"
	raise_label = $"../BetControl/RaiseLabel"
	total_bets_label = $"../TotalBetLabel"
	action_timer = $"../ActionTimer"
	game_manager_ref = $"../GameManager"
	deck_ref = $"../Deck"
	table_ref = $"../Table"
	action_log = $"../ActionLog"
	screen_size = get_viewport().size
	
func animate_card_to_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.65)
	
func action_label_action(action):
	action_scene_label.text = action
	action_scene_label.visible = true
	
	action_timer.start()
	await action_timer.timeout
	action_scene_label.visible = false
	
func draw_card_image(hand, node):
	var card_scene = load(CARD_SCENE)
	for i in range(hand.size()):
		var new_card = card_scene.instantiate()
		set_texture(hand[i], new_card)
		
		if node == $"../Player":
			add_card_to_hand(new_card, i)
		elif node == $"../Outlines":
			$"../Outlines".add_child(new_card)
			animate_card_to_position(new_card, game_manager_ref.OutlinePos[i])

func set_texture(card, object):
	var card_image_path = str("res://Assets/"+card+".png")
	object.get_node("Card_Image").texture = load(card_image_path)

func add_card_to_hand(card, index):
		$"../Player".add_child(card)
		update_hand_positions(card, index)
		
func update_hand_positions(card, index):
	var new_position = Vector2(clamp(calculate_card_position(index), 0, screen_size.x) , 
		clamp(deck_ref.chairs[table_ref.players.find("Player")].position.y - 100, 0, screen_size.y ))
	animate_card_to_position(card, new_position)
	
func calculate_card_position(index):
	var x_offset = deck_ref.chairs[table_ref.players.find("Player")].position.x + (CARD_WIDTH * index) - CARD_WIDTH / 2
	x_offset+=75
	return x_offset

func set_label(label, text=""):
	if label == total_bets_label:
		label.text = str("Total bets: ", text)
	if label == coin_label:
		label.text = str(table_ref.get_bets("Player"))
	else:
		label.text = str(text)

func update_action_log(action):
	action_log.text += str(action, "\n")
