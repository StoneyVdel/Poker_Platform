extends Panel

@onready var entries_container = $ScrollContainer/VBoxContainer

func clear():
	for child in entries_container.get_children():
		child.queue_free()

func add_entry(username: String, wins: int, chips: int):
	var label = Label.new()
	label.add_theme_font_size_override("font_size", 24)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	label.text = "%s |	 Wins: %d 	| Chips: %d" % [username, wins, chips]
	entries_container.add_child(label)

func error_entry():
	var label = Label.new()
	label.add_theme_font_size_override("font_size", 18)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = "Could not establish a connection to the server"
	entries_container.add_child(label)
