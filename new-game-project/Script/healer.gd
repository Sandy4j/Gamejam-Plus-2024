extends BaseUnit
class_name Healer

@export var heal_amount: float = 1.0
@export var heal_range: float = 50.0
var heal_timer: float = 0.1

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
	if not target and enemy_base and is_instance_valid(enemy_base):
		target = enemy_base

	if target and is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * move_speed
		sprite.flip_h = direction.x < 0
		move_and_slide()

func check_for_allies() -> void:
	var closest_ally = null
	var closest_distance = heal_range

	for body in detection_area.get_overlapping_bodies():
		if body == self or not is_instance_valid(body):
			continue
			
		if body.has_method("set_team") and body.team == team:
			var distance = global_position.distance_to(body.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_ally = body

	if closest_ally:
		target = closest_ally
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
