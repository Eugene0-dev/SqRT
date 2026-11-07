
@tool
class_name Counta
extends CharacterBody2D

@onready var nominal: Label = $Visuals/SubViewportContainer/SubViewport/Label
@onready var collect_field: Area2D = $Collect_Area2D

var speed: float = 120.0
var value: float = 0.0
var angle: float = 0.0

var world: World

signal numba_collected(numba: Numba)

func _ready() -> void:
	collect_field.body_entered.connect(collect_numba)

func _process(delta: float) -> void:
	var nominal_str = "%.1f" % value
	if nominal_str.ends_with(".0"):
		nominal_str = nominal_str.trim_suffix(".0")
	nominal.text = nominal_str

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		idle(delta)
		move_and_slide()
		return
		
	if not is_instance_valid(world) or world.numbas.is_empty():
		idle(delta)
	elif not world.numbas.is_empty():
		var numba_position := get_nearest_numba_position()
		move_to(numba_position, delta)
	
	move_and_slide()

func collect_numba(numba: Numba) -> void:
	value += numba.value
	numba_collected.emit(numba)
	numba.queue_free()

func move_to(pos: Vector2, delta) -> void:
	angle += delta
	var direction: Vector2 = global_position.direction_to(pos)
	velocity = direction * speed
	rotation = sin(angle*5) * deg_to_rad(10)

func get_nearest_numba_position() -> Vector2:
	if not is_instance_valid(world): return global_position
	var position: Vector2
	var distance: float = INF
	for numba in world.numbas:
		var d := global_position.distance_squared_to(numba.global_position)
		if d < distance:
			distance = d
			position = numba.global_position
			
	return position

func idle(delta: float) -> void:
	angle += delta
	velocity = Vector2(
		0.0, 
		tanh(sin(angle)*5.0)*10
	)
