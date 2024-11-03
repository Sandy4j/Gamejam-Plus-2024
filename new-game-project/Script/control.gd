extends Control

@onready var command_container = $CommandContainer
var player_manager: PlayerManager

func _ready():
	set_player_manager()

func set_player_manager():
	if player_manager:
		player_manager.spawn_keywords_updated.connect(_on_keywords_updated)
		_update_command_list(player_manager.get_spawn_commands())
		print("berhasuk")
	else:
		print("PlayerManager not found!")

func _on_keywords_updated(keywords: Dictionary):
	if player_manager:
		_update_command_list(player_manager.get_spawn_commands())

func _update_command_list(commands: Array):
	# Clear existing children
	for child in command_container.get_children():
		child.queue_free()
	
	# Add command information for each unit
	for command in commands:
		var label = Label.new()
		# Style the label
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_font_size_override("font_size", 16)
		
		# Add padding
		var padding = 5
		label.set("custom_minimum_size", Vector2(0, 30))
		label.set("theme_override_constants/margin_left", padding)
		label.set("theme_override_constants/margin_right", padding)
		
		label.text = "%s: ketik '%s %s' (Cost: %d gold)" % [
			command.unit.capitalize(),
			command.unit,
			command.keyword,
			command.cost
		]
		command_container.add_child(label)
