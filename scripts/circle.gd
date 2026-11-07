
class_name Circle
extends Shape

var square: Square

func setup(args: Dictionary) -> void:
	super(args)
	if args.has("square"): square = args["square"]

func _physics_process(delta: float) -> void:
	if is_instance_valid(square):
		var direction: Vector2 = global_position.direction_to(square.global_position)
		velocity = direction * speed
	else:
		velocity = Vector2(sin(global_position.y), -1) * speed
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var target := collision.get_collider()
		
		if target is Square:
			deal_damage(target)
			return

func deal_damage(target: Shape) -> void:
	if target is Square:
		target.take_damage(health)
		take_damage(health)
