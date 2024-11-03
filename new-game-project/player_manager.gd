extends Node
class_name PlayerManager

signal gold_updated(new_amount: int)
signal unit_spawned(unit_name: String, count: int)
signal notification_sent(message: String)
signal verification_word_changed(unit_name: String, new_word: String)

var gold: int = 100
var unit_costs = {
	"warrior": 20,
	"archer": 30,
	"healer": 50  # Tambahkan biaya untuk unit healer
}

var unit_scenes = {
	"warrior": preload("res://Actor/Warrior.tscn"),
	"archer": preload("res://Actor/Archer.tscn"),
	"healer": preload("res://Actor/healer.tscn")  # Tambahkan scene untuk unit healer
}

# Verification words for each unit type
var warrior_words = ["strike", "blade", "shield", "valor", "might", "sword"]
var archer_words = ["arrow", "bow", "quiver", "aim", "sharp", "shot"]
var healer_words = ["heal", "cure", "restore", "aid", "help", "revive"]  # Kata verifikasi untuk healer

# Inisialisasi dictionary dengan nilai default
var current_verification_words = {
	"warrior": "",
	"archer": "",
	"healer": ""  # Tambahkan entri untuk unit healer
} 

var spawn_point: Marker2D

func _ready():
	randomize()
	_refresh_all_verification_words()
	print_debug("Initial verification words:", current_verification_words)

func _init(initial_gold: int = 100):
	gold = initial_gold

func _refresh_verification_word(unit_name: String) -> void:
	if not unit_scenes.has(unit_name):
		return
		
	var word_list: Array
	match unit_name:
		"warrior":
			word_list = warrior_words.duplicate()
		"archer":
			word_list = archer_words.duplicate()
		"healer":  # Tambahkan logika untuk healer
			word_list = healer_words.duplicate()
		_:
			return
	
	# Pilih kata baru
	var new_word = word_list[randi() % word_list.size()]
	
	# Pastikan kata baru berbeda dengan yang sekarang
	while new_word == current_verification_words[unit_name] and word_list.size() > 1:
		new_word = word_list[randi() % word_list.size()]
	
	# Set kata baru
	current_verification_words[unit_name] = new_word
	print("Set verification word for ", unit_name, ": ", new_word)
	verification_word_changed.emit(unit_name, new_word)

func _refresh_all_verification_words() -> void:
	for unit_name in unit_scenes.keys():
		_refresh_verification_word(unit_name)

func set_spawn_point(point: Node2D):
	spawn_point = point
	print("Spawn point set at: ", spawn_point.global_position)

func add_gold(amount: int):
	gold += amount
	gold_updated.emit(gold)

func can_afford(unit_name: String) -> bool:
	if not unit_costs.has(unit_name):
		return false
	return gold >= unit_costs[unit_name]

# Fungsi untuk mencari unit name yang mirip
func find_similar_unit(typed_name: String) -> String:
	var valid_units = unit_scenes.keys()
	for unit in valid_units:
		if typed_name.length() >= 3 and unit.begins_with(typed_name):
			return unit
	return ""

func spawn_units(command: String, parent_node: Node) -> void:
	print("\n--- Spawn attempt ---")
	print("Received command: ", command)
	print("Current verification words: ", current_verification_words)
	
	var parts = command.split(" ")
	if parts.size() != 2:
		notification_sent.emit("Format: [unit_name] [verification_word]")
		return

	var unit_name = parts[0].to_lower()
	var typed_word = parts[1].to_lower()
	
	# Handle typos in unit name
	if not unit_scenes.has(unit_name):
		var suggested_unit = find_similar_unit(unit_name)
		if suggested_unit != "":
			notification_sent.emit("Mungkin maksud anda '" + suggested_unit + "'? ")
		else:
			notification_sent.emit("Unit tidak ditemukan: " + unit_name + ". Unit yang tersedia: " + ", ".join(unit_scenes.keys()))
		return
	
	print("Checking spawn for:")
	print("- Unit name: ", unit_name)
	print("- Typed word: ", typed_word)
	print("- Expected word: ", current_verification_words[unit_name])

	# Validate verification word
	if typed_word != current_verification_words[unit_name]:
		notification_sent.emit("Kata verifikasi salah untuk " + unit_name + ". Expected: " + current_verification_words[unit_name])
		return

	# Validate cost
	if not can_afford(unit_name):
		notification_sent.emit("Emas tidak cukup untuk spawn unit.")
		return

	# Validate spawn point
	if not spawn_point:
		notification_sent.emit("Spawn point belum di-set!")
		return

	# Spawn unit
	gold -= unit_costs[unit_name]
	gold_updated.emit(gold)

	var unit = unit_scenes[unit_name].instantiate()
	unit.position = spawn_point.global_position
	parent_node.add_child(unit)
	print("Unit spawned successfully at: ", unit.position)

	unit_spawned.emit(unit_name, 1)
	notification_sent.emit("Spawned " + unit_name)
	
	# Generate new verification word after successful spawn
	_refresh_verification_word(unit_name)

func get_unit_cost(unit_name: String) -> int:
	return unit_costs.get(unit_name, 0)

func get_current_gold() -> int:
	return gold

func get_current_verification_word(unit_name: String) -> String:
	return current_verification_words.get(unit_name, "")
