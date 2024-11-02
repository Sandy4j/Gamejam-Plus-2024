extends CharacterBody2D
class_name BaseUnit

enum UnitState { MOVING, ATTACKING, DEAD }

@export var move_speed: float = 100.0
@export var max_health: float = 100.0
@export var attack_damage: float = 10.0
@export var attack_speed: float = 1.0

var current_state: UnitState = UnitState.MOVING
var current_health: float
var team: String = "player"
var target: Node2D = null
var enemy_base: Node2D = null  # Changed type to Node2D to handle both base types
var attack_timer: float = 0.0

@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea
@onready var sprite: Sprite2D = $Sprite2D
@onready var health_bar: ProgressBar = $HealthBar


const KILL_REWARD: int = 20  

func _ready():
	current_health = max_health
	update_health_bar()
	
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)
	
	find_enemy_base()

func find_enemy_base() -> void:
	if not is_inside_tree():
		await ready
	
	# Check for both types of bases
	var target_groups = []
	if team == "player":
		target_groups.append("enemy_base")
	else:
		target_groups.append("player_base")
	
	for group in target_groups:
		var bases = get_tree().get_nodes_in_group(group)
		for base in bases:
			# Check if base is either GameBase or GameBased
			if (base is GameBase or base is GameBased) and base.team != team:
				enemy_base = base
				return

func _physics_process(delta: float) -> void:
	match current_state:
		UnitState.MOVING:
			move(delta)
		UnitState.ATTACKING:
			attack(delta)
		UnitState.DEAD:
			queue_free()

func move(delta: float) -> void:
	if not target and enemy_base and is_instance_valid(enemy_base):
		target = enemy_base
		
	if target and is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * move_speed
		sprite.flip_h = direction.x < 0
		move_and_slide()

func check_for_enemies() -> void:
	var closest_enemy = null
	var closest_distance = INF
	
	for body in detection_area.get_overlapping_bodies():
		if body == self or not is_instance_valid(body):
			continue
			
		if body.has_method("set_team") and body.team != team:
			var distance = global_position.distance_to(body.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_enemy = body
	
	if closest_enemy:
		target = closest_enemy
		current_state = UnitState.MOVING
	elif enemy_base and is_instance_valid(enemy_base):
		target = enemy_base
		current_state = UnitState.MOVING

func attack(delta: float) -> void:
	if not target or not is_instance_valid(target):
		current_state = UnitState.MOVING
		check_for_enemies()
		return
		
	attack_timer += delta
	if attack_timer >= 1.0 / attack_speed:
		attack_timer = 0.0
		deal_damage(target)

func deal_damage(target_node: Node2D) -> void:
	if target_node.has_method("take_damage"):
		target_node.take_damage(attack_damage)

func take_damage(amount: float) -> void:
	current_health -= amount
	update_health_bar()
	
	if current_health <= 0:
		die()

func die() -> void:
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager != null:
		if team == "player":
			if is_instance_valid(game_manager.enemy_commander):
				game_manager.enemy_commander.add_gold(KILL_REWARD)
				game_manager.show_notification("Enemy killed your unit! (+{0} gold)".format([KILL_REWARD]))
		else:
			if is_instance_valid(game_manager.player_commander):
				game_manager.player_commander.add_gold(KILL_REWARD)
				game_manager.show_notification("You killed an enemy unit! (+{0} gold)".format([KILL_REWARD]))
	current_state = UnitState.DEAD
	queue_free()

func update_health_bar() -> void:
	health_bar.value = (current_health / max_health) * 100

func set_team(new_team: String) -> void:
	team = new_team
	modulate = Color.RED if team == "enemy" else Color.BLUE
	await find_enemy_base()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body == self:
		return
		
	# Check for both GameBase and GameBased types
	var is_base = body is GameBase or body is GameBased
	
	# Prioritize attacking enemy units over the base
	if body.has_method("set_team") and body.team != team:
		target = body
		current_state = UnitState.MOVING
	# Only target base if no enemy units are in range
	elif is_base and body.team != team and not target:
		target = body
		current_state = UnitState.MOVING

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
		# Check if there are other enemies nearby
		check_for_enemies()

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body == target:
		current_state = UnitState.ATTACKING
	# If current target is base but we detect an enemy unit, switch target
	elif body.has_method("set_team") and body.team != team and target == enemy_base:
		target = body
		current_state = UnitState.ATTACKING

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body == target:
		current_state = UnitState.MOVING
		check_for_enemies()
