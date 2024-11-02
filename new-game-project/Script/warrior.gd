# warrior.gd
extends BaseUnit
class_name Warrior

func _ready():
	super._ready()
	# Set warrior-specific stats
	move_speed = 120.0
	max_health = 150.0
	attack_damage = 15.0
	attack_speed = 1.0
	current_health = max_health
	
	# Setup collision shapes untuk warrior
	var detection_shape: CollisionShape2D = CollisionShape2D.new()
	var detection_circle: CircleShape2D = CircleShape2D.new()
	detection_circle.radius = 150.0  # Radius deteksi
	detection_shape.shape = detection_circle
	detection_area.add_child(detection_shape)
	
	var attack_shape: CollisionShape2D = CollisionShape2D.new()
	var attack_circle: CircleShape2D = CircleShape2D.new()
	attack_circle.radius = 40.0  # Radius serangan melee
	attack_shape.shape = attack_circle
	attack_area.add_child(attack_shape)
