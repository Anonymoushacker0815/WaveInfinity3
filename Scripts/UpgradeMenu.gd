extends CanvasLayer

signal upgrade_selected(stat: String, amount: float)
signal continue_pressed

@export var stat_increase := 0.2

var upgrade_buttons = []

func _ready():
	var health_button = $Panel/VBoxContainer/HealthButton
	var speed_button = $Panel/VBoxContainer/SpeedButton
	var fire_rate_button = $Panel/VBoxContainer/FireRateButton
	var damage_button = $Panel/VBoxContainer/DamageButton
	var continue_button = $Panel/VBoxContainer/ContinueButton

	upgrade_buttons = [health_button, speed_button, fire_rate_button, damage_button]
	
	health_button.pressed.connect(func(): on_upgrade_clicked("health", stat_increase))
	speed_button.pressed.connect(func(): on_upgrade_clicked("speed", stat_increase))
	fire_rate_button.pressed.connect(func(): on_upgrade_clicked("fire_rate", stat_increase))
	damage_button.pressed.connect(func(): on_upgrade_clicked("damage", stat_increase))

	continue_button.pressed.connect(func():
		emit_signal("continue_pressed")
	)

func on_upgrade_clicked(stat: String, amount: float):
	var upgrade_text = ""
	match stat:
		"health":
			upgrade_text = "You picked: +20% Health"
		"speed":
			upgrade_text = "You picked: +20% Movement Speed"
		"fire_rate":
			upgrade_text = "You picked: +20% Fire Rate" 
		"damage":
			upgrade_text = "You picked: +20% Damage"
	$Panel/VBoxContainer/ChosenLabel.text = upgrade_text
	emit_signal("upgrade_selected", stat, amount)
	
	for btn in upgrade_buttons:
		btn.disabled = true
