extends Control

@onready var wave_label: Label = $Wave_Label
@onready var wave_progress_label: Label = $WaveProgress_Label
@onready var kills_label: Label = $Kills_Label
@onready var enemies_label: Label = $Enemies_Label

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	wave_label.text = "Wave: %d" % Global.wave_counter
	wave_progress_label.text = "%d%%" % ((1.0-Global.wave_progress)*100)
	kills_label.text = "kills: %d" % Global.kills_counter
	enemies_label.text = "πR: %d" % Global.circles_counter
