extends Node2D

var player_ref
var table_ref
var visuals_ref
@export var players : Array
@export var players_data2 : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_ref = $"../Player"
	visuals_ref = $"../Visuals"
	table_ref = $"../GameLogic"
	players = table_ref.players
	
func get_playersdata2():
	for i in players:
		players_data2[i]=table_ref[i][2]
		
@rpc("authority", "call_remote", "reliable", 0)
func opponent_card_draw(card_count, user, chair_id):
	pass
		
		
@rpc("authority", "call_remote", "reliable", 0)
func show_opponent_hand(players, players_data2):
	pass
