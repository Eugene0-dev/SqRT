extends Node

var upgrade_manager: UpgradeManager = UpgradeManager.new()
var wave_counter: int = 0
var kills_counter: int = 0
var circles_counter: int = 0
var wave_progress: float = 0.0

func get_upgrade_impact(upgrade: UpgradeManager.upgrade_types) -> float:
	var val: float = 0.0
	match upgrade:
		UpgradeManager.upgrade_types.PLUS: pass
		UpgradeManager.upgrade_types.MULTIPLY:
			val = 1+upgrade_manager.upgrades[upgrade]/10
		UpgradeManager.upgrade_types.DIVISION: pass
		UpgradeManager.upgrade_types.MINUS: pass
		UpgradeManager.upgrade_types.INC: pass
		UpgradeManager.upgrade_types.DEC: pass
		UpgradeManager.upgrade_types.FACTORIAL: pass
		UpgradeManager.upgrade_types.POW: pass
		UpgradeManager.upgrade_types.LOG: pass
	return val
