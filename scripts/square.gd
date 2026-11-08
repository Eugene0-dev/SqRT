
class_name Square
extends Shape

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
	tween.tween_property(self, "scale", Vector2(2, 2), 1)
	super()
	
	
	
	
	
	
	
	
