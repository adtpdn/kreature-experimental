extends Node2D

var attraction_radius = 50

@onready var sprite = $Sprite2D
@onready var attraction_area = $AttractionArea

func _ready():
	# Set up your floater sprite here
	pass

func _draw():
	draw_circle(Vector2.ZERO, attraction_radius, Color(0, 1, 0, 0.2))

func _process(_delta):
	queue_redraw()

# Remove the set_position method, as it's already defined in Node2D

func set_attraction_radius(radius):
	attraction_radius = radius
	var shape = CircleShape2D.new()
	shape.radius = radius
	attraction_area.set_deferred("shape", shape)
	queue_redraw()
