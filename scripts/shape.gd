
class_name Shape
extends CharacterBody2D

@export
var max_health: int = 100
var health: int
@export
var damage: int
@export
var speed: float = 100.0

signal shape_destroyed(shape: Shape)

func setup(args: Dictionary) -> void:
	if args.has("health"): max_health = args["health"]
	if args.has("speed"): speed = args["speed"]
	health = max_health

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0: die()

func deal_damage(target: Shape) -> void:
	pass

func die() -> void:
	shape_destroyed.emit(self)
	queue_free()
