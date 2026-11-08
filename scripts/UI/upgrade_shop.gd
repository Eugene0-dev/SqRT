
class_name UpgradeShop
extends Control

@onready var plus_upgrade_lvl: Label = $Panel/VBoxContainer/Plus_Update/Label2
@onready var plus_upgrade_btn: Button = $Panel/VBoxContainer/Plus_Update/Button
@onready var plus_cost: Label = $Panel/VBoxContainer/Plus_Update/Label4

@onready var multiply_upgrade_lvl: Label = $Panel/VBoxContainer/Multiply_Update/Label2
@onready var multiply_upgrade_btn: Button = $Panel/VBoxContainer/Multiply_Update/Button
@onready var multiply_cost: Label = $Panel/VBoxContainer/Multiply_Update/Label4

func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	if UpgradeManager.upgrades.has(UpgradeManager.upgrade_types.PLUS):
		plus_upgrade_lvl.text = "%d" % UpgradeManager.upgrades[UpgradeManager.upgrade_types.PLUS]
		plus_cost.text = "%d" % (UpgradeManager.upgrades[UpgradeManager.upgrade_types.PLUS]*20)
		if not int(plus_cost.text) < Global.numbas_count:
			plus_upgrade_btn.disabled = true
		else: plus_upgrade_btn.disabled = false

func _on_plus_button_pressed() -> void:
	UpgradeManager.ugrade_lvl_update(UpgradeManager.upgrade_types.PLUS)
