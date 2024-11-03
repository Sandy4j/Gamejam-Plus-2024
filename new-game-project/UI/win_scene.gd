extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"Credit-pop".visible = false
	$AnimationPlayer.play("ANim")
	await  get_tree().create_timer(5).timeout
	$Youwin.visible = false
	$AnimationPlayer.play("credit")
	$"Credit-pop".visible = true
	await  get_tree().create_timer(10).timeout
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file("res://UI/main_menu.tscn")
