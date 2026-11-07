
class_name World
extends Node2D

var circles: Array[Circle] = []
var triangles: Array[Triangle] = []
var square: Square

var counta: Counta
var numbas: Array[Numba] = []

enum shape_types {SQUARE, TRIANGLE, CIRCLE}
enum object_types {NUMBA, COUNTA}

var shape_scenes: Dictionary = {
	shape_types.SQUARE: load("res://scenes/square.tscn"),
	shape_types.TRIANGLE: load("res://scenes/triangle.tscn"),
	shape_types.CIRCLE: load("res://scenes/circle.tscn")
}

var object_scenes: Dictionary = {
	object_types.NUMBA: load("res://scenes/numba.tscn"),
	object_types.COUNTA: load("res://scenes/counta.tscn")
}

var wave_delay: float = 5.0
var wave_timer: float = wave_delay

var safe_radius: float = 400.0

func _ready() -> void:
	spawn(
		shape_types.SQUARE,
		get_viewport_rect().size/Vector2(2.0, 2.0),
		{"health": 200}
	)
	spawn(
		shape_types.TRIANGLE,
		square.global_position + Vector2(0.0, -100.0),
		{"health": 200, "square": square}
	)
	drop(
		object_types.COUNTA,
		Vector2.ZERO, {}
	)

func on_shape_destroyed(shape: Shape) -> void:
	if shape is Circle: 
		circles.erase(shape)
		Global.kills_counter += 1
		drop(object_types.NUMBA, shape.global_position, {"nominal": shape.max_health/100})
	if shape is Triangle: triangles.erase(shape)
	if shape is Square: square = null

func on_object_freed(object: Node2D) -> void:
	if object is Numba:
		numbas.erase(object)

func _process(delta: float) -> void:
	Global.circles_counter = len(circles)
	
	if wave_timer > 0:
		wave_timer -= delta
		Global.wave_progress = wave_timer / wave_delay
	else:
		wave_timer = wave_delay
		run_wave()

func random_position() -> Vector2:
	var center: = square.global_position
	var distance: = safe_radius + randf_range(0, 200)
	var angle: = randf() * TAU
	
	return center + Vector2(
		cos(angle), sin(angle)
	) * distance

func drop(object_type: object_types, pos: Vector2, args: Dictionary) -> void:
	var scene: PackedScene = object_scenes[object_type]
	var object := scene.instantiate()
	object.global_position = pos
	if object is Numba:
		if args.has("nominal"): object.value = args["nominal"]
		numbas.append(object)
	if object is Counta:
		counta = object
		counta.world = self
		counta.numba_collected.connect(on_object_freed)
	
	add_child(object)

func spawn(shape_type: shape_types, pos: Vector2, args: Dictionary) -> void:
	var scene: PackedScene =  shape_scenes[shape_type]
	var shape: Shape = scene.instantiate()
	shape.setup(args)
	shape.global_position = pos
	
	if shape is Circle: circles.append(shape)
	elif shape is Triangle: triangles.append(shape)
	elif shape is Square: square = shape
	
	shape.shape_destroyed.connect(on_shape_destroyed)
	add_child(shape)

func run_wave() -> void:
	if not is_instance_valid(square): return
	
	Global.wave_counter += 1
	var circle_amount = float(Global.wave_counter / 5.0 + 1)
	wave_delay += (Global.wave_counter % 10)/Global.wave_counter
	for i in range(circle_amount):
		spawn(
			shape_types.CIRCLE,
			random_position(),
			{
				"health": 100,
				"speed": 50,
				"square": square
			}
		)
