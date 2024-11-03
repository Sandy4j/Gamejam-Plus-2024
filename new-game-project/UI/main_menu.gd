extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dvd.play_bgm(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event):
	if Input.is_action_just_pressed("enter"):
		_on_play_btn_pressed()
	
func _on_play_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/loading.tscn")

func _on_quit_btn_pressed() -> void:
	get_tree().quit()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()
