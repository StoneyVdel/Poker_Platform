extends Control

@export var OptionsScene : PackedScene

var pause_menu=false

func _ready():
	$AnimationPlayer.play("RESET")
	
func resume():
	$AnimationPlayer.play_backwards("blur")
	$ColorRect.mouse_filter = 2
	
func pause():
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
	var Options = OptionsScene.instantiate()
	add_child(Options)


func _on_menu_pressed() -> void:
	get_parent().get_parent().player_ref.get_coins.rpc_id(1, get_parent().get_parent().player_ref.player_id)
	if ClientData.user_data.has("chips"):
		ClientData.user_data["chips"] += get_parent().get_parent().player_ref.coins
		print(ClientData.user_data["chips"])
	multiplayer.multiplayer_peer.disconnect_peer(1)
	get_tree().change_scene_to_file("res://Scene/menu.tscn")


func _on_quit_pressed() -> void:
	multiplayer.multiplayer_peer.disconnect_peer(1)
	get_tree().quit()

func _process(_delta):
	testEsc()
