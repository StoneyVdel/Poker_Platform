extends Panel

signal CreateAccount(username, email, phone, password)
signal UpdateAccount(username, email, phone, password)
var check = false

func _ready() -> void:
	$AnimationPlayer.play("RESET")
	$AnimationPlayer.play("blur")

func _process(delta: float) -> void:
	if ClientData.login_success == true && check==false:
		update_account()
		check=true

func update_account():
	$RichTextLabel.text = str("[center][b]Update account")
	$VBoxContainer/Create.text = str("Update")
	$VBoxContainer/HBoxContainer/UserNameText.text = ClientData.user_data["username"]
	$VBoxContainer/HBoxContainer2/EmailText.text = ClientData.user_data["email"]
	$VBoxContainer/HBoxContainer3/PhoneText.text = ClientData.user_data["phone"]
	$VBoxContainer/HBoxContainer4/PasswordText.text = ClientData.user_data["password"]
	$VBoxContainer/HBoxContainer5/RepeatPasswordText.text = ClientData.user_data["password"]
	
func _on_create_button_down():
	var username = $VBoxContainer/HBoxContainer/UserNameText.text
	var email = $VBoxContainer/HBoxContainer2/EmailText.text
	var phone = $VBoxContainer/HBoxContainer3/PhoneText.text
	var password = $VBoxContainer/HBoxContainer4/PasswordText.text
	var repeat_password = $VBoxContainer/HBoxContainer5/RepeatPasswordText.text

	if password != repeat_password:
		$ErrLabel.text = "Passwords do not match."
		print("Passwords do not match.")
		return

	if username == "" or email == "" or password == "":
		print("Please fill in all required fields.")
		$ErrLabel.text = "Please fill in all required fields."
		return
	
	if ClientData.login_success == false:
		CreateAccount.emit(username, email, phone, ClientData.hash_data(password))
	else:
		Database.update_account.rpc_id(1, username, email, phone, get_parent().hash_data(password))
	$AnimationPlayer.play_backwards("blur")
	queue_free()

func _on_close_button_down():
	$AnimationPlayer.play_backwards("blur")
	queue_free()
