extends Control
class_name KeywordsDisplay

# Reference ke label-label yang akan menampilkan keywords
var unit_labels = {}

func _ready():
	# Setup basic UI container
	var container = VBoxContainer.new()
	container.custom_minimum_size = Vector2(200, 0)
	add_child(container)
	
	# Tambahkan title
	var title = Label.new()
	title.text = "Unit Keywords"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(title)
	
	# Setup label untuk setiap unit
	var units = ["warrior", "archer", "healer"]
	for unit in units:
		var unit_container = HBoxContainer.new()
		container.add_child(unit_container)
		
		# Label untuk nama unit
		var name_label = Label.new()
		name_label.text = unit.capitalize() + ":"
		name_label.custom_minimum_size = Vector2(80, 0)
		unit_container.add_child(name_label)
		
		# Label untuk keyword
		var keyword_label = Label.new()
		keyword_label.text = "..."
		unit_container.add_child(keyword_label)
		
		# Simpan reference ke label keyword
		unit_labels[unit] = keyword_label

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
