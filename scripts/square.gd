
class_name Square
extends Shape

@onready var outline: MeshInstance2D = $CollisionShape2D/Outline_MeshInstance2D
@onready var fill: MeshInstance2D = $CollisionShape2D/MeshInstance2D

var origin_position: Vector2
var angle: float
var damping: float = 0.5

var angular_velocity: float = 0.0
var angular_damping: float = 2.5
var inertia: float =  100.0

func _ready() -> void:
	origin_position = global_position
	angle = rotation

func _physics_process(delta: float) -> void:
	var pos_offset := global_position.distance_to(origin_position)
	if pos_offset > 10:
		velocity += global_position.direction_to(origin_position)*delta*pos_offset
	move_and_slide()
	velocity *= exp(-damping*delta)
	rotation += angular_velocity * delta 
	angular_velocity *= exp(-angular_damping*delta)
	
	for i in get_slide_collision_count():
		var collide = get_slide_collision(i)
		var impact = collide.get_collider_velocity() - velocity
		var impulse = impact.project(-collide.get_normal())
		velocity += impulse
		
		var offset := collide.get_position() - global_position
		var torque := offset.cross(impulse)
		angular_velocity += torque / inertia
		

func die() -> void:
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(outline, "scale", Vector2(2, 2), 2)
	tween.tween_property(fill, "scale", Vector2(0.5, 0.5), 1)
	tween.tween_property(fill, "rotation", 800, 8)
	tween.tween_property(self, "scale", Vector2(10, 10), 1)
	await tween.finished
	super()
	
	
	
	
	
	
	
	
