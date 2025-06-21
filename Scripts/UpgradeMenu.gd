extends CanvasLayer

signal upgrade_selected(stat: String, amount: float, special: bool)
signal continue_pressed

@export var stat_increase := 0.2
@export var special_level_interval := 1

var upgrade_buttons = []
var current_level := 1

func set_level(level: int):
	current_level = level
	update_button_texts()

func update_button_texts():
	var is_special_level = current_level % special_level_interval == 0
	var special_style = preload("res://special_button_style.tres")  
	
	var health_button = $Panel/VBoxContainer/HealthButton
	var speed_button = $Panel/VBoxContainer/SpeedButton
	var fire_rate_button = $Panel/VBoxContainer/FireRateButton
	var damage_button = $Panel/VBoxContainer/DamageButton
	
	if is_special_level:
		health_button.text = "Extra Shot (+1 projectile)"
		speed_button.text = "Piercing Shot (+1 pierce)"
		fire_rate_button.text = "Spread Shot (+1 projectile)"
		damage_button.text = "Faster Bullets (+30% speed)"
		
		for button in [health_button, speed_button, fire_rate_button, damage_button]:
				button.add_theme_stylebox_override("normal", special_style)
				button.add_theme_stylebox_override("hover", special_style)
				button.add_theme_stylebox_override("pressed", special_style)
				
	else:
		health_button.text = "Health (+20%)"
		speed_button.text = "Speed (+20%)"
		fire_rate_button.text = "Fire Rate (+20%)"
		damage_button.text = "Damage (+20%)"
		
		for button in [health_button, speed_button, fire_rate_button, damage_button]:
			button.remove_theme_stylebox_override("normal")
			button.remove_theme_stylebox_override("hover")
			button.remove_theme_stylebox_override("pressed")


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
	var is_special_level = current_level % special_level_interval == 0
	var upgrade_text = ""
	
	if is_special_level:
		match stat:
			"health":
				upgrade_text = "You picked: Extra Shot"
			"speed":
				upgrade_text = "You picked: Piercing Shot"
			"fire_rate":
				upgrade_text = "You picked: Spread Shot"
			"damage":
				upgrade_text = "You picked: Faster Bullets"
	else:
		match stat:
			"health":
				upgrade_text = "You picked: +20% Health"
			"speed":
				upgrade_text = "You picked: +20% Speed"
			"fire_rate":
				upgrade_text = "You picked: +20% Fire Rate"
			"damage":
				upgrade_text = "You picked: +20% Damage"
	
	$Panel/VBoxContainer/ChosenLabel.text = upgrade_text
	emit_signal("upgrade_selected", stat, amount, is_special_level)
	
	for btn in upgrade_buttons:
		btn.disabled = true
