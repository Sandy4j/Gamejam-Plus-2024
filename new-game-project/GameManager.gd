extends Node2D

@onready var command_input: LineEdit = $CanvasLayer/Control/LineEdit
@onready var gold_label: Label = $CanvasLayer/Control/gold_label
@onready var notification_label: Label = $CanvasLayer/Control/notification_label
@onready var Egold_label: Label = $CanvasLayer/Control/Egold_label
@onready var player_base = $PlayerManager/BasePlayer
@onready var enemy_base = $EnemyCommander/BaseEnemy
@onready var UI = $CanvasLayer/UI

var player_commander: PlayerManager
var enemy_commander: EnemyCommanderManager

func _ready():
	add_to_group("game_manager")
	player_commander = PlayerManager.new()
	player_commander.set_spawn_point($PlayerManager/SpawnP)

	enemy_commander = EnemyCommanderManager.new()
	enemy_commander.set_spawn_point($EnemyCommander/SpawnAI)
	add_child(enemy_commander)

	player_commander.gold_updated.connect(_on_player_gold_updated)
	player_commander.notification_sent.connect(show_notification)
	enemy_commander.gold_updated.connect(_on_enemy_gold_updated)
	enemy_commander.unit_spawned.connect(_on_enemy_unit_spawned)
	command_input.connect("text_submitted", _on_command_submitted)
	gold_label.text = "Gold: " + str(player_commander.get_current_gold())
	Egold_label.text = "Gold: " + str(enemy_commander.get_current_gold())
	notification_label.text = ""

#func _on_gold_timer_timeout():
	#player_commander.add_gold(5)

func _on_player_gold_updated(new_amount: int):
	gold_label.text = "Gold: " + str(new_amount)
	enemy_commander.update_strategy(new_amount, get_player_unit_count())

func _on_enemy_gold_updated(_new_amount: int):
	Egold_label.text = "Gold: " + str(_new_amount)

func _on_enemy_unit_spawned(unit_name: String, _count: int):
	show_notification("Enemy spawned " + unit_name)

func _on_command_submitted(command: String):
	player_commander.spawn_units(command, self)
	command_input.clear()

func show_notification(message: String):
	notification_label.text = message
	await get_tree().create_timer(2.0).timeout
	notification_label.text = ""

func get_player_unit_count() -> int:
	# Logic untuk menghitung jumlah unit player
	# Implementasi tergantung bagaimana Anda melacak unit
	return 0  # Placeholder


func pause_game():
	enemy_commander.stop()

func resume_game():
	enemy_commander.resume()

func game_over():
	enemy_commander.stop()
	# Implementasi game over logic
