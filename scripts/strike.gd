class_name Strike
extends Shape

@onready var sight_field: Area2D = $Sight_Area2D
@onready var damage_field: Area2D = $Damage_Area2D

var square: Square
var rotation_speed: float = 5.0
var orbit_radius: float = 270.0
var angle: float = 0
var target: Shape
var enemies: Array[Shape] = []

func _ready() -> void:
	sight_field.body_entered.connect(on_sight_body_entered)
	sight_field.body_exited.connect(on_sight_body_exited)
	damage_field.body_entered.connect(on_damage_body_entered)

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

func _physics_process(delta: float) -> void:
	if enemies.is_empty():
		idle(delta)
	else: 
		aim(delta)
		var destiny = get_target_position()
		move_to(destiny)
	move_and_slide()

func aim(delta) -> void:
	target = null
	var min_distance: float = INF
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		var distance := global_position.distance_to(enemy.global_position)
		if distance < min_distance:
			min_distance = distance
			target = enemy
	
	if is_instance_valid(target):
		spin(target.global_position, delta)

func deal_damage(target: Shape) -> void:
	var target_hp: float = target.health
	var dmg: float = minf(target_hp,health)
	target.take_damage(dmg)
	take_damage(dmg)

func on_damage_body_entered(body:Node2D) -> void:
	if body is Circle: deal_damage(body)

func get_target_position() -> Vector2:
	if not is_instance_valid(target): 
		return global_position
	return target.global_position

func move_to(destiny:Vector2) -> void:
	var direction = global_position.direction_to(destiny)
	velocity = direction * speed

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
	angle += delta
	var destination := square.global_position + Vector2(
		cos(angle),
		sin(angle)
	) * orbit_radius
	
	velocity = global_position.direction_to(destination) * speed
	spin(square.global_position, delta, true)
