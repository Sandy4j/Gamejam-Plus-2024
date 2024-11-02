# arrow.gd
extends Area2D

var speed: float = 300.0
var damage: float = 15.0
var target: BaseUnit
var team: String
var direction: Vector2

func setup(arrow_damage: float, arrow_target: BaseUnit, arrow_team: String):
	damage = arrow_damage
	target = arrow_target
	team = arrow_team
	
	if target:
		direction = (target.global_position - global_position).normalized()
		rotation = direction.angle()

func _physics_process(delta):
	if not is_instance_valid(target):
		queue_free()
		return
		
	position += direction * speed * delta

func _on_body_entered(body: Node2D):
	if body is BaseUnit and body.team != team:
		body.take_damage(damage)
		queue_free()

func _on_lifetime_timer_timeout():
	queue_free()
