extends BaseUnit
class_name Healer

@export var heal_amount: float = 10.0
@export var heal_range: float = 50.0
var heal_timer: float = 0.0

func _ready() -> void:
	current_health = max_health
	update_health_bar()
	
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)

func _physics_process(delta: float) -> void:
	match current_state:
		UnitState.MOVING:
			move(delta)
		UnitState.ATTACKING:
			# Healer tidak menyerang, jadi kita bisa mengabaikan ini
			pass
		UnitState.DEAD:
			queue_free()

func move(delta: float) -> void:
	if target and is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * move_speed
		sprite.flip_h = direction.x < 0
		move_and_slide()
	else:
		# Jika tidak ada target, cari unit dengan HP terendah
		check_for_allies()

func check_for_allies() -> void:
	var lowest_health_ally = null
	var lowest_health = INF

	for body in detection_area.get_overlapping_bodies():
		if body == self or not is_instance_valid(body):
			continue
			
		if body.has_method("set_team") and body.team == team:
			# Pastikan unit memiliki metode take_damage untuk mendapatkan kesehatan
			if body.has_method("get_health"):
				var health = body.get_health()
				if health < lowest_health:
					lowest_health = health
					lowest_health_ally = body

	if lowest_health_ally:
		target = lowest_health_ally
		current_state = UnitState.MOVING

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body == self:
		return
		
	if body.has_method("set_team") and body.team == team:
		target = body
		current_state = UnitState.MOVING

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
		check_for_allies()

func _process(delta: float) -> void:
	if target and is_instance_valid(target):
		heal_timer += delta
		if heal_timer >= 1.0:  # Heal every second
			heal_timer = 0.0
			heal(target)

func heal(target_node: Node2D) -> void:
	if target_node.has_method("take_damage"):
		target_node.take_damage(-heal_amount)  # Healing is negative damage

# Tambahkan metode untuk mendapatkan kesehatan
func get_health() -> float:
	return current_health
