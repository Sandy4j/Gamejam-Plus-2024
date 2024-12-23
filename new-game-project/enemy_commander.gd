# enemy_commander.gd
extends Node
class_name EnemyCommanderManager

signal gold_updated(new_amount: int)
signal unit_spawned(unit_name: String, count: int)

var gold: int = 100
var spawn_cooldown: float = 0.0
var min_spawn_delay: float = 3.0  # Minimal delay antar spawn
var max_spawn_delay: float = 7.0  # Maksimal delay antar spawn

var unit_costs = {
	"warrior": 10,
	"archer": 15,
	"healer": 50  # Tambahkan biaya untuk unit healer
}

var unit_scenes = {
	"warrior": preload("res://AI/Warrior B.tscn"),
	"archer": preload("res://AI/ArcherB.tscn"),
	"healer": preload("res://AI/healerb.tscn")  # Tambahkan preload untuk unit healer
}

# Strategi spawn unit
var spawn_strategies = {
	"balanced": {"warrior": 0.4, "archer": 0.4, "healer": 0.2},  # 40-40-20 chance
	"aggressive": {"warrior": 0.6, "archer": 0.3, "healer": 0.1},  # Lebih banyak warrior
	"defensive": {"warrior": 0.3, "archer": 0.4, "healer": 0.3}   # Lebih banyak archer dan healer
}

var current_strategy: String = "balanced"
var spawn_point: Node2D
var active: bool = true

func add_gold(amount: int):
	gold += amount
	gold_updated.emit(gold)

func _init(initial_gold: int = 100):
	gold = initial_gold

func _ready():
	# Mulai AI loop
	start_ai_loop()

func set_spawn_point(point: Node2D):
	spawn_point = point

func start_ai_loop():
	while active:
		think_and_act()
		await get_tree().create_timer(randf_range(min_spawn_delay, max_spawn_delay)).timeout

func think_and_act():
	if not active or not spawn_point:
		return
	
	# Pilih unit untuk di-spawn berdasarkan strategi saat ini
	var unit_to_spawn = choose_unit_to_spawn()
	
	# Coba spawn unit jika gold cukup
	if can_afford(unit_to_spawn):
		spawn_unit(unit_to_spawn)

func can_afford(unit_name: String) -> bool:
	return gold >= unit_costs.get(unit_name, 0)

func choose_unit_to_spawn() -> String:
	var strategy = spawn_strategies[current_strategy]
	var random_value = randf()
	var cumulative_prob = 0.0
	
	for unit_name in strategy:
		cumulative_prob += strategy[unit_name]
		if random_value <= cumulative_prob:
			return unit_name
	
	return "warrior"  # Default fallback

func spawn_unit(unit_name: String):
	if not unit_scenes.has(unit_name):
		return

	var cost = unit_costs[unit_name]
	if gold >= cost:
		gold -= cost
		gold_updated.emit(gold)

		var unit = unit_scenes[unit_name].instantiate()
		unit.position = spawn_point.global_position
		# Set properti khusus untuk unit enemy
		if unit.has_method("set_team"):
			unit.set_team("enemy")
		get_parent().add_child(unit)
		unit_spawned.emit(unit_name, 1)

func update_strategy(player_gold: int, player_unit_count: int):
	# Logic sederhana untuk mengubah strategi berdasarkan kondisi game
	if player_gold > gold * 1.5:
		current_strategy = "aggressive"  # Player kaya, serang!
	elif player_unit_count > 5:
		current_strategy = "defensive"   # Player punya banyak unit, bertahan
	else:
		current_strategy = "balanced"    # Kondisi seimbang

func get_current_gold():
	return gold

func stop():
	active = false

func resume():
	active = true
	start_ai_loop()
