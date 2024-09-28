extends Control

signal bait_selected(bait)
signal toggle_casting_mode(enabled)

@onready var menu_button = $MenuButton
@onready var bait_menu = $BaitMenu
@onready var caught_fish_label = $BaitMenu/MenuContainer/HBoxContainer/CaughtFishLabel
@onready var sell_fish_button = $BaitMenu/MenuContainer/HBoxContainer/SellFishButton
@onready var casting_mode_button = $CastingModeButton

@onready var left_button = $VBoxContainer/Left
@onready var right_button = $VBoxContainer/Right
@onready var up_button = $VBoxContainer/Up
@onready var down_button = $VBoxContainer/Down

var caught_fish = 0
var player: CharacterBody2D
var casting_mode = false

func _ready():
	menu_button.pressed.connect(_on_menu_button_pressed)
	sell_fish_button.pressed.connect(_on_sell_fish_button_pressed)
	casting_mode_button.pressed.connect(_on_casting_mode_button_pressed)
	
	left_button.pressed.connect(func(): _on_direction_button_pressed("left"))
	right_button.pressed.connect(func(): _on_direction_button_pressed("right"))
	up_button.pressed.connect(func(): _on_direction_button_pressed("up"))
	down_button.pressed.connect(func(): _on_direction_button_pressed("down"))

func set_player(p: CharacterBody2D):
	player = p

func _on_direction_button_pressed(direction: String):
	if player:
		player.move_in_direction(direction)

func _on_menu_button_pressed():
	bait_menu.visible = !bait_menu.visible

func _on_bait_selected(bait):
	bait_selected.emit(bait)
	bait_menu.visible = false

func update_caught_fish(count):
	caught_fish = count
	caught_fish_label.text = "Caught Fish: " + str(caught_fish)

func _on_sell_fish_button_pressed():
	# Implement selling logic
	pass

func _on_casting_mode_button_pressed():
	casting_mode = !casting_mode
	toggle_casting_mode.emit(casting_mode)
	casting_mode_button.text = "Exit Casting Mode" if casting_mode else "Enter Casting Mode"
	print("UI toggled casting mode: ", casting_mode)  # Debug print
