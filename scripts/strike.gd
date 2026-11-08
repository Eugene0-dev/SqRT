class_name Strike
extends Triangle

func _ready() -> void:
	orbit_radius = 270
	contact_field = $Damage_Area2D
	sight_field = $Sight_Area2D
	super()

func _physics_process(delta: float) -> void:
	if enemies.is_empty():
		super(delta)
	else: 
		aim(delta)
		var destiny = get_target_position()
		var direction = global_position.direction_to(destiny)
		velocity = direction * speed
	move_and_slide()

func deal_damage(target: Shape, damage_type: String = "contact") -> void:
	var target_hp: float = target.health
	var dmg: float = minf(target_hp,health)
	target.take_damage(dmg)
	take_damage(dmg)

func get_target_position() -> Vector2:
	if not is_instance_valid(target): 
		return global_position
	return target.global_position
