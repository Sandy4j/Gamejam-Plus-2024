extends Node
class_name EnemyAIController

# Unit scenes
@export var warrior_scene: PackedScene
@export var archer_scene: PackedScene
@export var healer_scene: PackedScene

# Spawn settings
@export var spawn_point: Vector2
@export var gold_per_second: float = 5.0
@export var initial_gold: float = 100.0

# AI difficulty settings (Easy)
@export var min_spawn_interval: float = 3.0  # Minimum waktu antara spawn
@export var max_spawn_interval: float = 6.0   # Maximum waktu antara spawn
@export var min_gold_threshold: float = 50.0  # Minimal gold untuk mulai spawn

# Unit costs
const WARRIOR_COST = 20
const ARCHER_COST = 30
const HEALER_COST = 40

# State
var current_gold: float = 0.0
var can_spawn: bool = true
@onready var spawn_timer: Timer = $SpawnTimer
@onready var gold_timer: Timer = $GoldTimer

func _ready():
	current_gold = initial_gold
	
	# Setup gold generation timer
	gold_timer.wait_time = 1.0
	gold_timer.timeout.connect(_on_gold_timer_timeout)
	gold_timer.start()
	
	# Setup initial spawn timer
	_start_spawn_timer()

func _start_spawn_timer():
	# Random interval between min and max spawn time
	var spawn_interval = randf_range(min_spawn_interval, max_spawn_interval)
	spawn_timer.wait_time = spawn_interval
	spawn_timer.start()

func _on_gold_timer_timeout():
	current_gold += gold_per_second

func _on_spawn_timer_timeout():
	if current_gold >= min_gold_threshold:
		_try_spawn_unit()
	_start_spawn_timer()

func _try_spawn_unit():
	# Daftar unit yang bisa dibeli dengan gold saat ini
	var available_units = []
	
	if current_gold >= WARRIOR_COST:
		available_units.append("warrior")
	if current_gold >= ARCHER_COST:
		available_units.append("archer")
	if current_gold >= HEALER_COST:
		available_units.append("healer")
	
	if available_units.size() > 0:
		# Pilih unit secara random dari yang tersedia
		var chosen_unit = available_units[randi() % available_units.size()]
		
		# Spawn unit yang dipilih
		match chosen_unit:
			"warrior":
				if _spawn_unit(warrior_scene, WARRIOR_COST):
					print("Enemy spawned Warrior")
			"archer":
				if _spawn_unit(archer_scene, ARCHER_COST):
					print("Enemy spawned Archer")
			"healer":
				if _spawn_unit(healer_scene, HEALER_COST):
					print("Enemy spawned Healer")

func _spawn_unit(unit_scene: PackedScene, cost: int) -> bool:
	if current_gold >= cost:
		var unit = unit_scene.instantiate()
		unit.team = 1  # Set sebagai tim musuh
		unit.global_position = spawn_point
		get_tree().current_scene.add_child(unit)
		current_gold -= cost
		return true
	return false

# Fungsi untuk mendapatkan informasi status AI
func get_status() -> Dictionary:
	return {
		"current_gold": current_gold,
		"can_spawn": can_spawn,
		"next_spawn_time": spawn_timer.time_left
	}
