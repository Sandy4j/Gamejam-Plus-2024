extends Camera2D

var camera_speed = 200  # Kecepatan gerakan kamera
@onready var camera_limit = $CameraLimit  # Reference ke Area2D

func _ready():
	# Dapatkan collision shape dari Area2D
	var limit_shape = camera_limit.get_node("CollisionShape2D")
	var shape_extents = limit_shape.shape.extents
	var shape_position = limit_shape.global_position
	
	# Set batas kamera berdasarkan Area2D
	limit_left = shape_position.x - shape_extents.x
	limit_right = shape_position.x + shape_extents.x
	limit_top = shape_position.y - shape_extents.y
	limit_bottom = shape_position.y + shape_extents.y

func _process(delta):
	# Gerakan kamera
	if Input.is_action_pressed("right"):
		position.x += camera_speed * delta
	if Input.is_action_pressed("left"):
		position.x -= camera_speed * delta
