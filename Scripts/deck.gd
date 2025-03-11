extends Node2D

var card_db_ref
var deck_full = []
var deck_shuffled = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	card_db_ref = preload("res://Scripts/Card_Database.gd") 
	create_deck()
	shuffle_deck()

func create_deck():
	for i in range(card_db_ref.Suit.size()):
		for j in card_db_ref.Cards:
			deck_full.append(j+"_"+card_db_ref.Suit[i])
	
func shuffle_deck():
	randomize()
	deck_shuffled = deck_full
	deck_shuffled.shuffle()
	print(deck_shuffled)
	
func draw_card(card_count):

	var card_drawn_name = []
	
	for i in range(card_count):
		if deck_shuffled.size() != 0:
			card_drawn_name.insert(i, deck_shuffled[0])
			deck_shuffled.erase(card_drawn_name[i])
				
	return card_drawn_name
	
func animate_card_to_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.65)
