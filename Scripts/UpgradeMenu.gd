extends CanvasLayer

signal upgrade_selected(stat: String, amount: float)
signal continue_pressed

var upgrade_buttons = []

func _ready():
	var speed_button = $Panel/VBoxContainer/SpeedButton
	var fire_rate_button = $Panel/VBoxContainer/FireRateButton
	var damage_button = $Panel/VBoxContainer/DamageButton
	var continue_button = $Panel/VBoxContainer/ContinueButton

	upgrade_buttons = [speed_button, fire_rate_button, damage_button]

	speed_button.pressed.connect(func(): on_upgrade_clicked("speed", 0.1))
	fire_rate_button.pressed.connect(func(): on_upgrade_clicked("fire_rate", -0.015))
	damage_button.pressed.connect(func(): on_upgrade_clicked("damage", 1.25))

	continue_button.pressed.connect(func():
		emit_signal("continue_pressed")
	)

func on_upgrade_clicked(stat: String, amount: float):
	var upgrade_text = ""
	match stat:
		"speed":
			upgrade_text = "You picked: +10% Movement Speed"
		"fire_rate":
			upgrade_text = "You picked: +7.5% Fire Rate" 
		"damage":
			upgrade_text = "You picked: +1.25 Damage"
	$Panel/VBoxContainer/ChosenLabel.text = upgrade_text
	emit_signal("upgrade_selected", stat, amount)
	
	for btn in upgrade_buttons:
		btn.disabled = true
