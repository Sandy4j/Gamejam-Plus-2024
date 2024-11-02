# archer.gd
extends BaseUnit
class_name Archer

var arrow_scene = preload("res://Actor/Proyektil.tscn")

func _ready():
	super._ready()
	# Set archer-specific stats
	max_health = 100.0
	health = max_health
	attack_damage = 15.0
	attack_range = 150.0
	attack_cooldown = 1.5
	move_speed = 80.0
	detection_range = 200.0
	
	# Update health bar
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health

func attack():
	if not can_attack or not target:
		return
		
	can_attack = false
	if attack_timer:
		attack_timer.start()
	
	# Spawn arrow
	var arrow = arrow_scene.instantiate()
	arrow.global_position = global_position
	arrow.setup(attack_damage, target, team)
	get_parent().add_child(arrow)
	
	print("Archer shooting arrow at " + target.team)
	play_attack_animation()
