
class_name Numba
extends StaticBody2D

@onready var nominal_val: Label = $Label

var value: float = 1

func _ready() -> void:
	var nominal_str = "%.1f" % value
	if nominal_str.ends_with(".0"):
		nominal_str = nominal_str.trim_suffix(".0")
	nominal_val.text = nominal_str
