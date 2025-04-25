extends Control

func _ready():
	$AnimationPlayer.play("RESET")
	
func win():
	$State_Label.text = "You Win!"
	$State_Label.add_theme_font_size_override("font_size", 140)
	$AnimationPlayer.play("WinState")
	$ColorRect.mouse_filter = 0

func lose():
	$State_Label.text = "You Lose!"
	$State_Label.add_theme_font_size_override("font_size", 140)
	$AnimationPlayer.play("WinState")
	$ColorRect.mouse_filter = 0
