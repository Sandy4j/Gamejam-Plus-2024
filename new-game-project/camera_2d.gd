extends Camera2D

var camera_speed = 200  # Kecepatan gerakan kamera

func _process(delta):
	if Input.is_action_pressed("right"):
		position.x += camera_speed * delta
	if Input.is_action_pressed("left"):
		position.x -= camera_speed * delta
