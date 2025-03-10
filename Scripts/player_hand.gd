extends Node2D

const CARD_WIDTH = 124*1.36
var center_screen_x
var screen_size
var deck_ref

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	deck_ref = $"../Deck"
	center_screen_x = get_viewport().size.x / 2
	screen_size = get_viewport().size

func add_card_to_hand(card, index):
		$"../PlayerHand".add_child(card)
		update_hand_positions(card, index)
		pass
		
func update_hand_positions(card, index):
	var new_position = Vector2(clamp(calculate_card_position(index), 0, screen_size.x) , 
		clamp(screen_size.y - 130, 0, screen_size.y ))
	deck_ref.animate_card_to_position(card, new_position)
		
func calculate_card_position(index):
	var x_offset = center_screen_x + (CARD_WIDTH * index) - CARD_WIDTH / 2
	return x_offset
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
