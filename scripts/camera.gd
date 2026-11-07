
extends Camera2D

@onready var world: World = $".."

var actors: Dictionary[String, Shape]

var deadzone: float = 8.0

func _ready() -> void:
	get_square_actor()
	get_triangle_actor()

func get_square_actor() -> bool:
	if is_instance_valid(world.square):
		actors.set("square", world.square)
		return true
	
	return false

func get_triangle_actor() -> bool:
	if not world.triangles.is_empty():
		actors.set("triangle", world.triangles[0])
		return true
	
	return false

func _process(delta: float) -> void:
	if not is_instance_valid(actors.get("square")): 
		get_square_actor()
	if not is_instance_valid(actors.get("triangle")):
		get_triangle_actor()
	
	if not is_instance_valid(actors.get("triangle")): return
	
	var destination := actors["triangle"].global_position
	
	if is_instance_valid(actors.get("square")):
		destination = actors["square"].global_position.lerp(
			actors["triangle"].global_position,
			0.35
		)
	
	var offset := destination - global_position
	
	if offset.length_squared() > deadzone*deadzone:
		global_position = global_position.lerp(
			destination,
			3.0 * delta
		)
