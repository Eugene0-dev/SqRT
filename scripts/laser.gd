
class_name Laser
extends Node2D

@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var segment: SegmentShape2D = collision.shape as SegmentShape2D
@onready var visual: ColorRect = $Area2D/ColorRect
@onready var attack_area: Area2D = $Area2D

var max_distance: float = 1
var blast_speed: float = 1

var firing: bool = false
var damage_takers: Array[Shape]

signal blast_colided(bodies: Array[Shape])

func _ready() -> void:
	attack_area.body_entered.connect(on_attack_body_entered)

func fire() -> void:
	firing = true

func on_attack_body_entered(body: Node2D):
	if body is Shape and not body in damage_takers:
		damage_takers.append(body)
	blast_colided.emit(damage_takers)

func _process(delta: float) -> void:
	if firing: 
		visual.size.y = minf(
			visual.size.y + blast_speed * delta,
			max_distance
		)
		
		if visual.size.y >= max_distance:
			firing = false
	else:
		visual.size.y = maxf(
			visual.size.y - blast_speed * delta * 10,
			0.0
		)
		
	segment.a = Vector2.ZERO
	segment.b = Vector2(0.0, visual.size.y)
