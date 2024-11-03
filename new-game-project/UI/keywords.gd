extends Control

# Onready vars untuk mengakses node labels
@onready var warrior_keyword = $PanelContainer/MarginContainer/VBoxContainer/WarriorContainer/WarriorKeyword
@onready var archer_keyword = $PanelContainer/MarginContainer/VBoxContainer/ArcherContainer/ArcherKeyword
@onready var healer_keyword = $PanelContainer/MarginContainer/VBoxContainer/HealerContainer/HealerKeyword

# Dictionary untuk memetakan nama unit ke label
var unit_labels = {}

func _ready():
	# Setup dictionary untuk mapping unit ke label
	unit_labels = {
		"warrior": warrior_keyword,
		"archer": archer_keyword,
		"healer": healer_keyword
	}

# Fungsi untuk update keyword specific unit
func update_keyword(unit_name: String, new_word: String):
	if unit_labels.has(unit_name):
		unit_labels[unit_name].text = new_word

# Fungsi untuk setup koneksi dengan PlayerManager
func connect_to_player_manager(player_manager: PlayerManager):
	# Koneksikan signal verification_word_changed
	player_manager.verification_word_changed.connect(update_keyword)
	
	# Update semua keywords yang ada
	for unit in unit_labels.keys():
		var current_word = player_manager.get_current_verification_word(unit)
		update_keyword(unit, current_word)
