extends Control

var analytics

func _ready() -> void:
	$AnimationPlayer.play("RESET")
	$AnimationPlayer.play("blur")
	$PanelContainer/VBoxContainer/HBoxContainer/Analytics.button_pressed = get_parent().get_parent().get_parent().visuals_ref.analytics.visible
	
func _on_button_pressed() -> void:
	$AnimationPlayer.play_backwards("blur")
	queue_free()

func _on_analytics_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		get_parent().get_parent().get_parent().visuals_ref.analytics_visible(true)
	else:
		get_parent().get_parent().get_parent().visuals_ref.analytics_visible(false)

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.
