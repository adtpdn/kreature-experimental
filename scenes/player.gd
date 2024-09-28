extends CharacterBody2D

signal moved(position)
signal cast(position)

@export var speed = 200
@export var cast_range = 100
var last_movement = Vector2.ZERO
var casting_mode = false

@onready var cast_area = $CastArea

func _ready():
	cast_area.visible = false

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	
	if input_vector != Vector2.ZERO:
		velocity = input_vector.normalized() * speed
		last_movement = input_vector
		rotation = input_vector.angle()
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
	moved.emit(global_position)

func _unhandled_input(event):
	if casting_mode and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var cast_position = get_global_mouse_position()
		if cast_position.distance_to(global_position) <= cast_range:
			cast.emit(cast_position)

func move_in_direction(direction: String):
	match direction:
		"left":
			velocity = Vector2.LEFT * speed
		"right":
			velocity = Vector2.RIGHT * speed
		"up":
			velocity = Vector2.UP * speed
		"down":
			velocity = Vector2.DOWN * speed
	
	last_movement = velocity.normalized()
	rotation = last_movement.angle()
	move_and_slide()
	moved.emit(global_position)

func toggle_casting_mode(enabled: bool):
	casting_mode = enabled
	cast_area.visible = enabled
