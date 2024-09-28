extends Node2D

@export var current_bait : Bait
var caught_fish = 0
var active_floater: Node2D = null

@onready var player = $Player
@onready var ui = $UI/Control
@onready var fish_spawner = $FishSpawner

var Floater = preload("res://scenes/floater.tscn")  # Make sure to create this scene

func _ready():
	ui.set_player(player)
	ui.bait_selected.connect(_on_bait_selected)
	ui.toggle_casting_mode.connect(_on_toggle_casting_mode)
	fish_spawner.fish_caught.connect(_on_fish_caught)
	player.moved.connect(_on_player_moved)
	player.cast.connect(_on_player_cast)
	print("Game ready, signals connected")  # Debug print

func _on_bait_selected(bait):
	current_bait = bait
	print("Bait selected: ", bait.name if bait else "None")  # Debug print

func _on_fish_caught():
	if current_bait and randf() < current_bait.catch_rate:
		caught_fish += 1
		ui.update_caught_fish(caught_fish)
	reset_bait()

func _on_player_moved(new_position):
	pass

func _on_player_cast(cast_position):
	print("Cast received at position: ", cast_position)  # Debug print
	if current_bait:
		if active_floater:
			active_floater.queue_free()
		active_floater = Floater.instantiate()
		add_child(active_floater)
		active_floater.global_position = cast_position
		active_floater.set_attraction_radius(50)  # Adjust as needed
		print("Floater created at: ", active_floater.global_position)  # Debug print
		attract_nearby_fish(cast_position)
	else:
		print("No bait selected")  # Debug print

func attract_nearby_fish(bait_position):
	for fish in fish_spawner.get_children():
		if fish is Area2D and fish.position.distance_to(bait_position) <= 100:  # Adjust attraction range as needed
			fish.attract_to_bait(bait_position)

func reset_bait():
	if active_floater:
		active_floater.queue_free()
		active_floater = null
	for fish in fish_spawner.get_children():
		if fish is Area2D:
			fish.reset_attraction()

func _on_toggle_casting_mode(enabled):
	player.toggle_casting_mode(enabled)
	print("Casting mode toggled in game: ", enabled)  # Debug print
