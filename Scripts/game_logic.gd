extends Node2D

const CARD_SCENE = "res://Scene/card.tscn"
const OPPONENT_CARD_SCENE = "res://Scene/opponent_card.tscn"
var draw_card_count = 2
var card_db_ref
var deck_ref
var player_count = 2
var dealer
var players = ["Host", "Opp"]
var hands = {}

#var OutlinePos = []
	#OutlinePos.append($"../Outlines/Outline5".position)
	#OutlinePos.append($"../Outlines/Outline4".position)
	#OutlinePos.append($"../Outlines/Outline3".position)
	#OutlinePos.append($"../Outlines/Outline2".position)
	#OutlinePos.append($"../Outlines/Outline1".position)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	card_db_ref = preload("res://Scripts/Card_Database.gd")
	deck_ref = $"../Deck"
	dealer = players.pick_random()
	initial_draw()
	pass
	

func initial_draw():
	var card_count = 2
	var node
	for i in players:
		hands[i] = deck_ref.draw_card(card_count)
		if i == "Host":
			node = $"../PlayerHand"
			draw_card_image(hands[i], node)
		elif i == "Opp" :
			opponent_card_draw(hands[i])
			
func draw_card_image(hand, node):
	var card_scene = preload(CARD_SCENE)
	for i in range(hand.size()):
		var new_card = card_scene.instantiate()
		var card_image_path = str("res://Assets/"+hand[i]+".png")
		new_card.get_node("Card_Image").texture = load(card_image_path)
		node.add_card_to_hand(new_card, i)
		
func opponent_card_draw(hand):
	var opponent_card_scene = preload(OPPONENT_CARD_SCENE)
	for i in range(hand.size()):
		var opponent_card = opponent_card_scene.instantiate()
		$"../OpponentHand".add_child(opponent_card)
		$"../OpponentHand".update_hand_positions(opponent_card, i)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
