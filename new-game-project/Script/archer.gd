# archer.gd
extends BaseUnit
class_name Archer

var arrow_scene = preload("res://Actor/Proyektil.tscn")
var is_attacking: bool = false 
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
	is_attacking = true  # Set attacking state to true
	if attack_timer:
		attack_timer.start()
	
	# Spawn arrow
	var arrow = arrow_scene.instantiate()
	arrow.global_position = global_position
	arrow.setup(attack_damage, target, team)
	get_parent().add_child(arrow)
	
	print("Archer shooting arrow at " + target.team)
	#play_attack_animation()
	
	# Add a small timer to reset the attacking state
	await get_tree().create_timer(0.5).timeout
	is_attacking = false

# Override the move_to_target function from BaseUnit
func move_to_target():
	if is_attacking:  # Don't move if attacking
		velocity = Vector2.ZERO
		return
	
	# Call parent implementation if not attacking
	super.move_to_target()

# Override the move_forward function from BaseUnit
func move_forward():
	if is_attacking:  # Don't move if attacking
		velocity = Vector2.ZERO
		return
		
	# Call parent implementation if not attacking
	super.move_forward()

func take_damage(damage: float):
	health -= damage
	if health_bar:
		health_bar.value = health
	if health <= 0:
		die()
