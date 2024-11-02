extends CharacterBody2D
class_name BaseUnit

# Properti dasar unit
var team: String = "player"
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

# Tambahan node untuk area deteksi dan serangan
@onready var detection_area: Area2D = $DetectionArea if has_node("DetectionArea") else null
@onready var attack_raycast: RayCast2D = $AttackRayCast if has_node("AttackRayCast") else null

# Target detection
var target: BaseUnit = null
var detection_range: float = 100.0

func _ready():
	# Pastikan semua node yang diperlukan ada
	await get_tree().create_timer(0.1).timeout # Tunggu sedikit untuk memastikan semua node siap
	
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
	
	if attack_timer:
		attack_timer.wait_time = attack_cooldown
		attack_timer.one_shot = true
	
	# Setup detection area
	if detection_area:
		detection_area.connect("body_entered", Callable(self, "_on_detection_area_entered"))
		detection_area.connect("body_exited", Callable(self, "_on_detection_area_exited"))
	
	# Setup attack raycast
	if attack_raycast:
		attack_raycast.enabled = true
		attack_raycast.target_position = Vector2(attack_range, 0)
		attack_raycast.collision_mask = 2  # Sesuaikan dengan layer unit lawan
	
	# Set team dan arah
	setup_team(team)

func _physics_process(_delta):
	if health <= 0:
		return
		
	find_target_with_detection_area()
	
	if target:
		var distance = global_position.distance_to(target.global_position)
		if distance <= attack_range and can_attack:
			check_attack_raycast()
		else:
			move_to_target()
	else:
		move_forward()

func find_target_with_detection_area():
	if detection_area:
		var overlapping_bodies = detection_area.get_overlapping_bodies()
		var closest_target = null
		var closest_distance = detection_range
		
		for body in overlapping_bodies:
			if body is BaseUnit and body.team != team:
				var distance = global_position.distance_to(body.global_position)
				if distance < closest_distance:
					closest_distance = distance
					closest_target = body
		
		target = closest_target

func check_attack_raycast():
	if attack_raycast and attack_raycast.is_colliding():
		var collider = attack_raycast.get_collider()
		if collider is BaseUnit and collider.team != team:
			attack()

func setup_team(new_team: String):
	team = new_team
	if sprite:
		if team == "enemy":
			sprite.flip_h = true
			move_speed = -abs(move_speed)  # Pastikan bergerak ke kiri
			if attack_raycast:
				attack_raycast.target_position.x = -attack_range
		else:
			sprite.flip_h = false
			move_speed = abs(move_speed)   # Pastikan bergerak ke kanan
			if attack_raycast:
				attack_raycast.target_position.x = attack_range

func _on_detection_area_entered(body):
	# Tambahan logika jika diperlukan saat unit masuk area deteksi
	pass

func _on_detection_area_exited(body):
	# Tambahan logika jika diperlukan saat unit keluar area deteksi
	pass

# Fungsi-fungsi lain tetap sama seperti sebelumnya
func set_team(new_team: String):
	setup_team(new_team)

func move_to_target():
	if target and is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * abs(move_speed)
		move_and_slide()

func move_forward():
	velocity = Vector2(move_speed, 0)
	move_and_slide()

func attack():
	if not can_attack:
		return
		
	can_attack = false
	if attack_timer:
		attack_timer.start()
	
	if target and is_instance_valid(target) and target.has_method("take_damage"):
		target.take_damage(attack_damage)
		play_attack_animation()

func take_damage(damage: float):
	health -= damage
	if health_bar:
		health_bar.value = health
	
	if health <= 0:
		die()
	else:
		play_hit_animation()

func die():
	# Disable collision dan physics
	set_physics_process(false)
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	
	# Play death animation
	play_death_animation()
	
	# Remove dari scene
	await get_tree().create_timer(1.0).timeout
	queue_free()

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
