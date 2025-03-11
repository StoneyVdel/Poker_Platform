extends Node2D

const CARD_SCENE = "res://Scene/card.tscn"

const CARD_WIDTH = 124*1.36
var center_screen_x
var screen_size
var deck_ref
var table_ref
var game_manager_ref

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	deck_ref = $"../Deck"
	table_ref = $"../Table"
	center_screen_x = get_viewport().size.x / 2
	screen_size = get_viewport().size
	game_manager_ref = $"../GameManager"
	
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
		pass
		
func update_hand_positions(card, index):
	var new_position = Vector2(clamp(calculate_card_position(index), 0, screen_size.x) , 
		clamp(screen_size.y - 130, 0, screen_size.y ))
	deck_ref.animate_card_to_position(card, new_position)
		
func calculate_card_position(index):
	var x_offset = center_screen_x + (CARD_WIDTH * index) - CARD_WIDTH / 2
	return x_offset
