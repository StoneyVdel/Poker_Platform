extends Control

var pause_menu=false

func _ready():
	$AnimationPlayer.play("RESET")
	
func resume():
	#get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	$ColorRect.mouse_filter = 2
	
func pause():
	#get_tree().paused = true
	$AnimationPlayer.play("blur")
	$ColorRect.mouse_filter = 0
	
func testEsc():
	if Input.is_action_just_pressed("esc") and pause_menu==false: #and !get_tree().paused:
		pause()
		pause_menu=true
	elif Input.is_action_just_pressed("esc") and pause_menu==true: #and get_tree().paused:
		resume()
		pause_menu=false

func _on_resume_pressed() -> void:
	resume()


func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()

func _process(_delta):
	testEsc()
