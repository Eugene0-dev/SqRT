extends CanvasLayer

@onready var info_view: Control = $Info
@onready var upgrade_shop: Control = $Upgrade_Shop

func _ready() -> void:
	info_view.visible = true
	upgrade_shop.visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		upgrade_shop.visible = !upgrade_shop.visible
		info_view.visible = !info_view.visible
