# warrior.gd
extends BaseUnit
class_name Warrior

func _ready():
	super._ready()
	# Set warrior-specific stats
	max_health = 150.0
	health = max_health
	attack_damage = 20.0
	attack_range = 30.0
	attack_cooldown = 1.0
	move_speed = 100.0
	detection_range = 150.0
	
	# Update health bar
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health

func attack():
	if not can_attack:
		return
		
	can_attack = false
	if attack_timer:
		attack_timer.start()
