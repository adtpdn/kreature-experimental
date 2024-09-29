extends Node2D

@export var current_bait : Bait
var caught_fish = 0
var active_floater: Node2D = null
var is_reeling = false

@onready var player = $Player
@onready var ui = $UI/Control
@onready var fish_spawner = $FishSpawner

var Floater = preload("res://scenes/floater.tscn")

func _ready():
	ui.set_player(player)
	ui.bait_selected.connect(_on_bait_selected)
	ui.toggle_casting_mode.connect(_on_toggle_casting_mode)
	fish_spawner.fish_caught.connect(_on_fish_caught)
	player.moved.connect(_on_player_moved)
	player.cast.connect(_on_player_cast)
	player.reel_started.connect(_on_reel_started)
	player.reel_ended.connect(_on_reel_ended)

func _process(delta):
	if is_reeling and active_floater:
		var direction = (player.global_position - active_floater.global_position).normalized()
		active_floater.global_position += direction * 100 * delta
		update_fish_attraction(active_floater.global_position)
		if active_floater.global_position.distance_to(player.global_position) < 10:
			remove_floater()
			is_reeling = false

func _on_fish_caught():
	if current_bait and randf() < current_bait.catch_rate:
		caught_fish += 1
		ui.update_caught_fish(caught_fish)
	reset_bait()

func _on_player_moved(new_position):
	pass

func _on_player_cast(cast_position):
	if current_bait:
		if active_floater:
			remove_floater()
		create_floater(cast_position)
	else:
		print("No bait selected, cannot cast")

func remove_floater():
	if active_floater:
		active_floater.queue_free()
		active_floater = null
	update_fish_attraction(null)

func _on_reel_started():
	is_reeling = true

func _on_reel_ended():
	is_reeling = false

func create_floater(position):
	active_floater = Floater.instantiate()
	add_child(active_floater)
	active_floater.global_position = position
	active_floater.set_attraction_radius(50)
	update_fish_attraction(position)

func update_fish_attraction(bait_position):
	for fish in fish_spawner.get_children():
		if fish is Area2D:
			fish.update_bait_position(bait_position)

func _on_bait_selected(bait):
	current_bait = bait

func reset_bait():
	if active_floater:
		active_floater.queue_free()
		active_floater = null
	update_fish_attraction(null)

func _on_toggle_casting_mode(enabled):
	player.toggle_casting_mode(enabled)
