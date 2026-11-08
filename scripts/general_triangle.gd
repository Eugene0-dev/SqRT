
class_name GeneralTriangle
extends Triangle

@onready var laser: Laser = $Laser
@onready var charge_indicator = $MeshInstance2D
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

func _ready() -> void:
	sight_field = $SightField_Area2D
	contact_field = $Damage_Area2D
	super()
	laser.max_distance = max_laser_distance
	laser.blast_speed = laser_blast_speed
	
	charge_material = charge_indicator.material as ShaderMaterial
	
	dash_field.body_entered.connect(on_dash_body_entered)
	dash_field.body_exited.connect(on_dash_body_exited)
	laser.blast_colided.connect(on_blast_collided)

func take_damage(amount: float) -> void: pass

func _physics_process(delta: float) -> void:
	if enemies.is_empty():
		super(delta)
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

func on_blast_collided(damage_takers: Array[Shape]) -> void:
	for taker in damage_takers:
		if is_instance_valid(taker) and taker is Circle:
			deal_damage(taker)

func on_dash_body_entered(body: Node2D) -> void: 
	if body is Circle:
		is_dashing = true

func on_dash_body_exited(body: Node2D) -> void: 
	is_dashing = false

func deal_damage(target: Shape, damage_type: String = "blast") -> void:
	match damage_type:
		"blast": target.take_damage(basic_blast_damage*blast_damage_modifier)
		_: super(target, damage_type)

func fire() -> void:
	if not is_charged: return
	laser.fire()
	is_charged = false
	charge_timer += charge_longing

func charge(delta: float) -> void:
	if is_charged: return
	charge_timer -= delta
	if charge_timer <= 0:
		is_charged = true

func get_firing_position() -> Vector2:
	if not is_instance_valid(square) or not is_instance_valid(target): 
		return global_position
	
	if is_charged:
		return square.global_position.lerp(
			target.global_position, 0.5
		)
	
	return target.global_position
