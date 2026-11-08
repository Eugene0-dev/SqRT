
class_name Shape
extends CharacterBody2D

@export var max_health: float = 100
@export var damage: int
@export var speed: float = 100.0

var health: float

signal shape_destroyed(shape: Shape)

func setup(args: Dictionary) -> void:
	if args.has("health"): max_health = args["health"]
	if args.has("speed"): speed = args["speed"]
	health = max_health

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0: die()

func deal_damage(target: Shape) -> void:
	pass

func die() -> void:
	shape_destroyed.emit(self)
	queue_free()
