# archer.gd
extends BaseUnit
class_name Archer

var arrow_scene = preload("res://Actor/Proyektil.tscn")  # Pastikan membuat scene Arrow.tscn"res://Actor/Proyektil.tscn"
var preferred_distance: float = 200.0  # Jarak ideal untuk menyerang

func _ready():
	super._ready()
	# Set archer-specific stats
	move_speed = 100.0
	max_health = 100.0
	attack_damage = 12.0
	attack_speed = 0.8
	current_health = max_health
	
	# Setup collision shapes untuk archer
	var detection_shape: CollisionShape2D = CollisionShape2D.new()
	var detection_circle: CircleShape2D = CircleShape2D.new()
	detection_circle.radius = 250.0  # Radius deteksi lebih besar
	detection_shape.shape = detection_circle
	detection_area.add_child(detection_shape)
	
	var attack_shape: CollisionShape2D = CollisionShape2D.new()
	var attack_circle: CircleShape2D = CircleShape2D.new()
	attack_circle.radius = 200.0  # Radius serangan ranged
	attack_shape.shape = attack_circle
	attack_area.add_child(attack_shape)

func move(delta: float) -> void:
	if target and is_instance_valid(target):
		var distance_to_target = global_position.distance_to(target.global_position)
		if distance_to_target < preferred_distance:
			# Mundur jika terlalu dekat dengan target
			var direction = (global_position - target.global_position).normalized()
			velocity = direction * move_speed
		else:
			# Maju jika terlalu jauh dari target
			var direction = (target.global_position - global_position).normalized()
			velocity = direction * move_speed
		sprite.flip_h = velocity.x < 0
		move_and_slide()
	else:
		super.move(delta)

func deal_damage(target_node: Node2D) -> void:
	if target and is_instance_valid(target):
		var arrow = arrow_scene.instantiate()
		arrow.position = global_position
		arrow.team = team
		arrow.damage = attack_damage
		arrow.target = target
		get_parent().add_child(arrow)
