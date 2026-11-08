extends Node

enum upgrade_types {
	PLUS, MULTIPLY, DIVISION, MINUS, INC, DEC, FACTORIAL, POW, LOG
}

var upgrades: Dictionary[upgrade_types, int]

func _ready() -> void:
	for type in upgrade_types:
		upgrades.set(type, 0)

func ugrade_lvl_update(type: upgrade_types) -> void:
	upgrades[type] += 1
