extends Node2D

const OPPONENT_CARD_SCENE = "res://Scene/opponent_card.tscn"

var actions = ["Call", "Raise", "Fold"] 
const CARD_WIDTH = 124*1
var center_screen_x
var screen_size
var deck_ref
var obj_path = []
var player_ref
var table_ref
var opponent_card_node
var visuals_ref

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	deck_ref = $"../Deck"
	player_ref = $"../Player"
	table_ref = $"../Table"
	visuals_ref = $"../Visuals"
	center_screen_x = get_viewport().size.x / 2
	screen_size = get_viewport().size
		
func opponent_card_draw(card_count, user):
	var opponent_card_scene = preload(OPPONENT_CARD_SCENE)
	deck_ref.chairs[table_ref.players.find(user)].add_to_group(str(user))
	for i in range(card_count):
		opponent_card_node = opponent_card_scene.instantiate()
		$"../OpponentHand".add_child(opponent_card_node)
		$"../OpponentHand".update_hand_positions(opponent_card_node, i, user)
		opponent_card_node.add_to_group(str(user,"cards"))
	pass
		
func update_hand_positions(card, index, user):
	#Change so that the position changes depending on the player amount
	var new_position = Vector2(clamp(calculate_card_position(index, user), 0, screen_size.x) , 
		clamp( deck_ref.chairs[table_ref.players.find(user)].position.y - 100, 0, screen_size.y ))
	visuals_ref.animate_card_to_position(card, new_position)
	
func calculate_card_position(index, user):
	var x_offset = deck_ref.chairs[table_ref.players.find(user)].position.x + (CARD_WIDTH * index) - CARD_WIDTH / 2
	x_offset+=60
	return x_offset

func show_opponent_hand():
	for i in table_ref.players:
		if i != "Player":
				for j in range(table_ref.players_data[i][2].size()):
					visuals_ref.set_texture(table_ref.players_data[i][2][j], get_tree().get_nodes_in_group(str(i,"cards"))[j])
