extends Node2D

var player_ref
var opponent_ref
var visuals_ref

func _ready() -> void:
	player_ref = $Player
	opponent_ref = $Opponent
	visuals_ref = $Visuals

func get_cards():
	pass
	
func _process(delta: float) -> void:
	pass
	
