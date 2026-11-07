
class_name Triangle
extends Shape

@onready var laser: Laser = $Laser
@onready var charge_indicator := $MeshInstance2D
@onready var sight_field: Area2D = $SightField_Area2D
@onready var contact_field: Area2D = $Damage_Area2D
@onready var dash_field: Area2D = $Dash_Area2D

var is_dashing: bool = false
var dash_modifier: float = 2.5
var is_charged: bool = false
var charge_longing: float = 5.0
var charge_timer: float = charge_longing
var max_laser_distance: float = 500.0
var laser_blast_speed: float = 2000.0
var charge_material: ShaderMaterial
var charge_progress: float:
	get:
		return 1.0 - charge_timer / charge_longing
var basic_blast_damage: float = 100.0
var blast_damage_modifier: float = 1.0
var basic_contact_damage: float = 100.0
var contact_damage_modifier: float = 1.0
var rotation_speed: float = 5.0
var orbit_radius: float = 400.0
var angular_speed: float = 1.0

var square: Square
var angle: float = 0

var enemies: Array[Circle] = []
var target: Circle
var is_target_aimed: bool = false

func _ready() -> void:
	laser.max_distance = max_laser_distance
	laser.blast_speed = laser_blast_speed
	
	charge_material = charge_indicator.material as ShaderMaterial
	
	sight_field.body_entered.connect(on_body_entered)
	sight_field.body_exited.connect(on_body_exited)
	contact_field.body_entered.connect(on_contact_body_entered)
	dash_field.body_entered.connect(on_dash_body_entered)
	dash_field.body_exited.connect(on_dash_body_exited)
	laser.blast_colided.connect(on_blast_collided)

func on_blast_collided(damage_takers: Array[Shape]) -> void:
	for taker in damage_takers:
		if is_instance_valid(taker) and taker is Circle:
			deal_damage(taker)

func on_dash_body_entered(body: Node2D) -> void: 
	if body is Circle:
		is_dashing = true

func on_dash_body_exited(body: Node2D) -> void: 
	is_dashing = false

func on_contact_body_entered(body: Node2D) -> void:
	if body is Circle:
		deal_damage(body, "contact")

func on_body_entered(body: Node2D) -> void:
	if body is Circle:
		enemies.append(body)

func on_body_exited(body: Node2D) -> void:
	if body is Circle:
		enemies.erase(body)

func setup(args: Dictionary) -> void:
	super(args)
	if args.has("square"): square = args["square"]

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
		var direction := spin(target.global_position, delta)
		var angle_diff := absf(angle_difference(
			global_rotation - PI/2,
			direction.angle()
		))
		is_target_aimed = angle_diff < deg_to_rad(5.0)

func get_firing_position() -> Vector2:
	if not is_instance_valid(square) or not is_instance_valid(target): 
		return global_position
	
	if is_charged:
		return square.global_position.lerp(
			target.global_position, 0.5
		)
	
	return target.global_position

func charge(delta: float) -> void:
	if is_charged: return
	charge_timer -= delta
	if charge_timer <= 0:
		is_charged = true

func fire() -> void:
	if not is_charged: return
	laser.fire()
	is_charged = false
	charge_timer += charge_longing

func deal_damage(target: Shape, damage_type: String = "blast") -> void:
	match damage_type:
		"blast": target.take_damage(basic_blast_damage*blast_damage_modifier)
		"contact": target.take_damage(basic_contact_damage*contact_damage_modifier)

func _process(delta: float) -> void:
	
	if enemies.is_empty():
		if is_instance_valid(square): 
			idle(delta)
		else:
			alt_idle(delta)
	else:
		aim(delta)
		var destination: Vector2 = get_firing_position()
		if is_dashing:
			velocity = global_position.direction_to(destination) * speed*dash_modifier
		else:
			velocity = global_position.direction_to(destination) * speed

	if not is_charged: charge(delta)
	elif is_instance_valid(target) and is_target_aimed: fire()
	
	charge_material.set_shader_parameter("charge", charge_progress)
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
	angle += delta
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
