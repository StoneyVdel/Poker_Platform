#extends Node2D
#
#signal left_mouse_button_clicked
#signal left_mouse_button_released
#
#const COLLISION_MASK_DECK = 1
#const COLLISION_MASK_CALL = 4
#const COLLISION_MASK_FOLD = 16
#const COLLISION_MASK_RAISE = 8
#var game_logic_ref
#
#func _ready() -> void:
	#game_logic_ref = $"../GameManager"
	#
##func _input(event):
	##if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		##if event.pressed:
			##emit_signal("left_mouse_button_clicked")
			##raycast_at_cursor()
		##else:
			##emit_signal("left_mouse_button_released")
			##
##func raycast_at_cursor():
	##var space_state = get_world_2d().direct_space_state
	##var parameters = PhysicsPointQueryParameters2D.new()
	##parameters.position = get_global_mouse_position()
	##parameters.collide_with_areas = true
	###parameters.collision_mask = 1
	##var result = space_state.intersect_point(parameters)
	##if result.size() > 0:
		##var result_collision_mask = result[0].collider.collision_mask
		##if result_collision_mask == COLLISION_MASK_DECK:
			##pass
		##if result_collision_mask == COLLISION_MASK_CALL:
			##print("Call")
		##if result_collision_mask == COLLISION_MASK_FOLD:
			##print("FOLD")
			##game_logic_ref.players.erase("Host")
			##
			##game_logic_ref.player_turn = "Opp"
		##if result_collision_mask == COLLISION_MASK_RAISE:
			##print("RAISE")
