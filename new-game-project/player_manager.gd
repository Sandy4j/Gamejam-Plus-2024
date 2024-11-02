extends Node
class_name PlayerManager

signal gold_updated(new_amount: int)
signal unit_spawned(unit_name: String, count: int)
signal notification_sent(message: String)

var gold: int = 100
var unit_costs = {
	"warrior": 10,
	"archer": 15
}

var unit_scenes = {
	"warrior": preload("res://Actor/Warrior.tscn"),
	"archer": preload("res://Actor/Archer.tscn")
}

var spawn_point: Marker2D

func _init(initial_gold: int = 100):
	gold = initial_gold

func set_spawn_point(point: Node2D):
	spawn_point = point

func add_gold(amount: int):
	gold += amount
	gold_updated.emit(gold)

func can_afford(unit_name: String, count: int = 1) -> bool:
	if not unit_costs.has(unit_name):
		return false
	return gold >= (unit_costs[unit_name] * count)

func spawn_units(command: String, parent_node: Node) -> void:
	var parts = command.split(" ")
	var unit_name = parts[0].to_lower()
	var unit_count = 1

	if parts.size() == 2:
		unit_count = int(parts[1])

	# Validasi unit exists
	if not unit_scenes.has(unit_name):
		notification_sent.emit("Unit tidak ditemukan: " + unit_name)
		return

	# Validasi cost
	var total_cost = unit_costs[unit_name] * unit_count
	if not can_afford(unit_name, unit_count):
		notification_sent.emit("Emas tidak cukup untuk spawn unit.")
		return

	# Spawn units
	gold -= total_cost
	gold_updated.emit(gold)

	for i in range(unit_count):
		if spawn_point:
			var unit = unit_scenes[unit_name].instantiate()
			unit.position = spawn_point.global_position + Vector2(i * 10, 0)
			parent_node.add_child(unit)
			await parent_node.get_tree().create_timer(0.5).timeout

	unit_spawned.emit(unit_name, unit_count)
	notification_sent.emit("Spawned " + str(unit_count) + " " + unit_name + "(s).")

# Fungsi untuk mendapatkan unit cost
func get_unit_cost(unit_name: String) -> int:
	return unit_costs.get(unit_name, 0)

# Fungsi untuk mendapatkan gold saat ini
func get_current_gold() -> int:
	return gold
