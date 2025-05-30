extends Node2D

const OPPONENT_CARD_SCENE = "res://Scene/opponent_card.tscn"

var actions = ["Call", "Raise", "Fold"] 
const CARD_WIDTH = 124*1
var center_screen_x
var screen_size
var player_ref
var opponent_card_node
var visuals_ref
var chairs

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_ref = $"../Player"
	visuals_ref = $"../Visuals"
	chairs = $"../Chairs".get_children()
	screen_size = get_viewport().size

@rpc("authority", "call_remote", "reliable", 0)
func opponent_card_draw(card_count, user):
	if user != player_ref.player_id:
		var chair_id = visuals_ref.chair_info_player.find_key(user)
		var opponent_card_scene = preload(OPPONENT_CARD_SCENE)
		chairs[chair_id].add_to_group(str(user))
		for i in range(card_count):
			opponent_card_node = opponent_card_scene.instantiate()
			$".".add_child(opponent_card_node)
			visuals_ref.update_hand_positions(opponent_card_node, i, chair_id)
			opponent_card_node.add_to_group(str(user,"cards"))
	pass
		
		
@rpc("authority", "call_remote", "reliable", 0)
func show_opponent_hand(players:Array, players_data:Dictionary):
	if players_data.size() > 0:
		for i in players:
			if i != player_ref.player_id:
					for j in range(players_data[i].size()):
						visuals_ref.set_texture(players_data[i][j], get_tree().get_nodes_in_group(str(i,"cards"))[j])
