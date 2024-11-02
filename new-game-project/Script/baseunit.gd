# base_unit.gd
extends CharacterBody2D
class_name BaseUnit

# Properti dasar unit
var team: String = "player"  # Default team
var health: float = 100.0
var max_health: float = 100.0
var move_speed: float = 100.0
var attack_damage: float = 10.0
var attack_range: float = 50.0
var attack_cooldown: float = 1.0
var can_attack: bool = true

# Node references
@onready var attack_timer: Timer = $AttackTimer if has_node("AttackTimer") else null
@onready var animation_player: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null
@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null
@onready var health_bar: ProgressBar = $HealthBar if has_node("HealthBar") else null
@onready var attack_raycast: RayCast2D = $AttackRayCast if has_node("AttackRayCast") else null

# Target variables
var target: Node2D = null  # Bisa BaseUnit atau StaticBody2D (base)
var enemy_base: Node2D = null
var detection_range: float = 200.0

func _ready():
	await get_tree().create_timer(0.1).timeout
	
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
	
	if attack_timer:
		attack_timer.wait_time = attack_cooldown
		attack_timer.one_shot = true
	
	if attack_raycast:
		attack_raycast.target_position = Vector2(attack_range, 0)
		# Set collision mask sesuai dengan layer collision yang digunakan
		attack_raycast.collision_mask = 2  # Sesuaikan dengan layer units dan base
	
	setup_team(team)
	find_enemy_base()

func _physics_process(_delta):
	if health <= 0:
		return
		
	update_target()
	
	if target:
		var distance = global_position.distance_to(target.global_position)
		if distance <= attack_range and can_attack:
			attack()
		else:
			move_to_target()
	else:
		move_forward()

func setup_team(new_team: String):
	team = new_team
	if sprite:
		if team == "enemy":
			sprite.flip_h = true
			move_speed = -abs(move_speed)
			if attack_raycast:
				attack_raycast.target_position.x = -abs(attack_raycast.target_position.x)
		else:
			sprite.flip_h = false
			move_speed = abs(move_speed)
			if attack_raycast:
				attack_raycast.target_position.x = abs(attack_raycast.target_position.x)

func set_team(new_team: String):
	setup_team(new_team)

func find_enemy_base():
	var base_group = "enemy_base" if team == "player" else "player_base"
	var bases = get_tree().get_nodes_in_group(base_group)
	if bases.size() > 0:
		enemy_base = bases[0]

func update_target():
	# Check for units first using raycast
	if attack_raycast and attack_raycast.is_colliding():
		var collider = attack_raycast.get_collider()
		if collider is BaseUnit and collider.team != team:
			target = collider
			return
		elif collider.is_in_group("player_base") and team == "enemy":
			target = collider
			return
		elif collider.is_in_group("enemy_base") and team == "player":
			target = collider
			return
	
	# If no unit found, target the enemy base
	if enemy_base and is_instance_valid(enemy_base):
		target = enemy_base

func move_to_target():
	if target and is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * abs(move_speed)
		move_and_slide()

func move_forward():
	velocity = Vector2(move_speed, 0)
	move_and_slide()

func attack():
	if not can_attack or not target:
		return
		
	can_attack = false
	if attack_timer:
		attack_timer.start()
	
	# Check if target is in range using raycast
	if attack_raycast and attack_raycast.is_colliding():
		var collider = attack_raycast.get_collider()
		if collider == target:
			if target.has_method("take_damage"):
				target.take_damage(attack_damage)
			#play_attack_animation()


	#else:
		#play_hit_animation()

func die():
	set_physics_process(false)
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	#play_death_animation()
	#
	#await get_tree().create_timer(1.0).timeout
	queue_free()

# Animation functions tetap sama...
func play_attack_animation():
	if animation_player and animation_player.has_animation("attack"):
		animation_player.play("attack")

func play_hit_animation():
	if animation_player and animation_player.has_animation("hit"):
		animation_player.play("hit")

func play_death_animation():
	if animation_player and animation_player.has_animation("death"):
		animation_player.play("death")

func _on_attack_timer_timeout():
	can_attack = true
