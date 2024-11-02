extends Control

@onready var Player_HPBar = $Bg/Player_HP
@onready var Enemy_HPBar = $Bg/Enemy_HP

func _ready() -> void:
	pass

func _on_base_player_player_set(val) -> void:
	Player_HPBar.value = val

func _on_base_enemy_enem_set(val) -> void:
	Enemy_HPBar.value = val
