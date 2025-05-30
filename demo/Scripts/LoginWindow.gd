extends Panel

@export var CreateAccountWindow: PackedScene

var login_success = false
var password

func _on_cancel_button_down():
	queue_free()
	

func _on_create_account_button_down():
	var create_account_window = CreateAccountWindow.instantiate()
	add_child(create_account_window)
	create_account_window.CreateAccount.connect(_on_create_account_received)

func _on_create_account_received(username, email, phone, password):
	Database.create_account.rpc_id(1, username, email, phone, password)

func _on_login_button_down():
	var email = $Email.text
	password = $Password.text
	Database.verify_login.rpc_id(1, email, ClientData.hash_data(password))
	await get_tree().create_timer(2).timeout
	got_login()
	
func got_login():
	var user_data = Database.user
	if user_data != null:
		login_success=true
		ClientData.user_data = user_data
		ClientData.user_data["password"] = password
		ClientData.login_success = login_success
		get_parent().set_account_btn()
		get_parent().coins_label.text = str(ClientData.user_data["chips"])
		queue_free()
	else:
		$ErrLabel.text = "Email or password is incorect"
