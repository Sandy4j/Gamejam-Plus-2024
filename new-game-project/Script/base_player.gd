# game_base.gd
extends StaticBody2D
class_name GameBase

signal player_set 

@onready var health_bar = $HealthBar if has_node("HealthBar") else null
@export var team: String = "player"
@export var max_health: float = 1000.0

var health: float

func _ready():
	health = max_health
	emit_signal("player_set", health)
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
	
	# Add to appropriate group
	if team == "player":
		add_to_group("player_base")
	else:
		add_to_group("enemy_base")

func take_damage(damage: float):
	health -= damage
	emit_signal("player_set", health)
	if health_bar:
		health_bar.value = health
	
	if health <= 0:
		#on_base_destroyed()
		pass
		
func on_base_destroyed():
	# Implement game over logic here
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		if team == "player":
			game_manager.on_player_base_destroyed()
		else:
			game_manager.on_enemy_base_destroyed()
