extends Node2D

signal fish_caught

var Fish = preload("res://scenes/fish.tscn")
var spawn_area: Rect2
var max_fish = 5
var spawn_interval = 2.0

func _ready():
	spawn_area = get_viewport_rect()
	$SpawnTimer.wait_time = spawn_interval
	$SpawnTimer.start()

func _on_SpawnTimer_timeout():
	if get_child_count() < max_fish:
		spawn_fish()

func spawn_fish():
	var fish = Fish.instantiate()
	fish.position = Vector2(
		randf_range(spawn_area.position.x, spawn_area.end.x),
		randf_range(spawn_area.position.y, spawn_area.end.y)
	)
	fish.caught.connect(_on_Fish_caught)
	add_child(fish)
	print("Fish spawned at: ", fish.position)  # Debug print

func _on_Fish_caught(fish):
	fish_caught.emit()
	fish.queue_free()
	print("Fish caught and removed")  # Debug print
