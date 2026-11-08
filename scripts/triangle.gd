
class_name Triangle
extends Shape

var sight_field: Area2D
var contact_field: Area2D 

var basic_contact_damage: float = 100.0
var contact_damage_modifier: float = 1.0
var rotation_speed: float = 5.0
var orbit_radius: float = 200.0
var angular_speed: float = 1.0

var square: Square
var angle: float = 0

var enemies: Array[Circle] = []
var target: Circle
var is_target_aimed: bool = false

func _ready() -> void:
	if is_instance_valid(sight_field):
		sight_field.body_entered.connect(on_sight_body_entered)
		sight_field.body_exited.connect(on_sight_body_exited)
	if is_instance_valid(contact_field):
		contact_field.body_entered.connect(on_contact_body_entered)

func on_contact_body_entered(body: Node2D) -> void:
	if body is Circle:
		deal_damage(body, "contact")

func on_sight_body_entered(body: Node2D) -> void:
	if body is Circle:
		enemies.append(body)

func on_sight_body_exited(body: Node2D) -> void:
	if body is Circle:
		enemies.erase(body)

func setup(args: Dictionary) -> void:
	super(args)
	if args.has("square"): square = args["square"]
	if args.has("speed"): speed = args["speed"]

func aim(delta) -> void:
	target = null
	is_target_aimed = false
	
	var min_distance: float = INF
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		var distance := global_position.distance_to(enemy.global_position)
		if distance < min_distance:
			min_distance = distance
			target = enemy
	
	if is_instance_valid(target):
		var direction := spin(target.global_position, delta)
		var angle_diff := absf(angle_difference(
			global_rotation - PI/2,
			direction.angle()
		))
		is_target_aimed = angle_diff < deg_to_rad(5.0)

func deal_damage(target: Shape, damage_type: String = "contact") -> void:
	match damage_type:
		"contact": target.take_damage(basic_contact_damage*contact_damage_modifier)

func _physics_process(delta: float) -> void:
	if is_instance_valid(square): 
		idle(delta)
	else:
		alt_idle(delta)
	
	move_and_slide()

func spin(destiny: Vector2, delta, back: bool = false) -> Vector2:
	var direction: Vector2 = global_position.direction_to(destiny)
	var offset := -PI / 2 if back else PI / 2
	var target_rotation := direction.angle() + offset
	
	rotation = lerp_angle(
		rotation,
		target_rotation,
		rotation_speed * delta
	)
	return direction

func idle(delta: float) -> void:
	angle += delta/2
	var destination := square.global_position + Vector2(
		cos(angle),
		sin(angle)
	) * orbit_radius
	
	var tanget := Vector2(-sin(angle), cos(angle) * (orbit_radius * angular_speed))
	var correction := global_position.direction_to(destination) * global_position.distance_to(destination) * 5.0
	
	velocity = tanget + correction
	spin(square.global_position, delta, true)

func alt_idle(delta: float) -> void:
	angle += angular_speed * delta
	velocity = Vector2(
		sin(angle), cos(angle/4)
	) * speed
	
	rotate(delta)
