extends Area2D

var speed: float = 300.0
var damage: float = 10.0
var team: String = "player"
var target: Node2D

func _ready():
	# Setup collision untuk mendeteksi semua target yang mungkin
	set_collision_mask_value(1, true)   # Mask untuk unit
	set_collision_mask_value(2, true)   # Mask untuk base
	
	
	# Setup collision shape if not already present
	if get_child_count() == 0:
		var collision_shape: CollisionShape2D = CollisionShape2D.new()
		var shape: CircleShape2D = CircleShape2D.new()
		shape.radius = 5.0
		collision_shape.shape = shape
		add_child(collision_shape)

func _physics_process(delta: float) -> void:
	if not target or not is_instance_valid(target):
		queue_free()
		return
		
	var direction = (target.global_position - global_position).normalized()
	position += direction * speed * delta
	rotation = direction.angle()

func is_valid_target(node: Node) -> bool:
	if not node:
		return false
	if node is GameBase or node is GameBased:
		return node.team != team

	if node.has_method("set_team"):
		return node.team != team
		
	return false

func _on_body_entered(body: Node2D) -> void:
	if is_valid_target(body):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()

# Optional: Menambahkan method untuk mengatur target
func set_target(new_target: Node2D) -> void:
	target = new_target
	
# Optional: Menambahkan method untuk mengatur team
func set_team(new_team: String) -> void:
	team = new_team
