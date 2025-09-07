extends Node2D

var selected_card 
var screen_size
var player_ref
var visuals_ref

func _ready() -> void:
	player_ref = $"../Player"
	visuals_ref = $"../Visuals"
	screen_size = get_viewport_rect().size
	
func _process(delta: float) -> void:
	if selected_card:
		var mouse_pos = get_global_mouse_position()
		selected_card.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x), clamp(mouse_pos.y, 0, screen_size.y))
	
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card = raycast_check_for_card()
			if card:
				start_drag(card)
		else:
			if selected_card:
				finish_drag()
			
func start_drag(card):
	selected_card = card
	
func finish_drag():
	visuals_ref.animate_card_to_position(selected_card, str_to_var(selected_card.pos["last_position"]))
	selected_card = null
	
func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = 2
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null
