extends Node2D

var cast_range = 100

func _draw():
	draw_circle(Vector2.ZERO, cast_range, Color(1, 1, 1, 0.2))

func _process(_delta):
	queue_redraw()

func set_cast_range(new_range):
	cast_range = new_range
	queue_redraw()
