extends CharacterBody2D

signal moved(position)
signal cast(position)
signal reel_started
signal reel_ended

enum PlayerState { MOVING, IDLE, CASTING, REELING }

@export var max_speed = 200
@export var acceleration = 500
@export var deceleration = 300
@export var rotation_speed = 2.0
@export var cast_range = 100

var current_state = PlayerState.IDLE
var last_movement = Vector2.ZERO
var casting_mode = false
var is_reeling = false
var input_vector = Vector2.ZERO

@onready var cast_area = $CastArea
@onready var sprite = $Sprite2D

func _ready():
	cast_area.visible = false

func _input(event):
	if current_state == PlayerState.CASTING:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			var cast_position = get_global_mouse_position()
			print("Mouse clicked at: ", cast_position)
			if cast_position.distance_to(global_position) <= cast_range:
				if event.pressed:
					print("Casting at position: ", cast_position)
					cast.emit(cast_position)
					change_state(PlayerState.REELING)
				else:
					change_state(PlayerState.CASTING)

func _physics_process(delta):
	match current_state:
		PlayerState.MOVING, PlayerState.IDLE:
			process_movement(delta)
		PlayerState.CASTING:
			process_casting()
		PlayerState.REELING:
			process_reeling()
	
	moved.emit(global_position)

func process_movement(delta):
	input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		apply_acceleration(delta)
		rotate_player()  # Changed this line
		change_state(PlayerState.MOVING)
	else:
		apply_friction(delta)
		if velocity.length() < 1:
			change_state(PlayerState.IDLE)
	
	move_and_slide()

func apply_acceleration(delta):
	velocity += input_vector * acceleration * delta
	velocity = velocity.limit_length(max_speed)

func apply_friction(delta):
	if velocity.length() > 0:
		velocity -= velocity.normalized() * deceleration * delta
		if velocity.length() < 1:
			velocity = Vector2.ZERO

func rotate_player():
	if velocity != Vector2.ZERO:
		sprite.rotation = velocity.angle()

func process_casting():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		change_state(PlayerState.REELING)

func process_reeling():
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		change_state(PlayerState.CASTING)

func _unhandled_input(event):
	if current_state == PlayerState.CASTING and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var cast_position = get_global_mouse_position()
		if cast_position.distance_to(global_position) <= cast_range:
			cast.emit(cast_position)

func move_in_direction(direction: String):
	match direction:
		"left":
			input_vector = Vector2.LEFT
		"right":
			input_vector = Vector2.RIGHT
		"up":
			input_vector = Vector2.UP
		"down":
			input_vector = Vector2.DOWN
	
	change_state(PlayerState.MOVING)

func toggle_casting_mode(enabled: bool):
	casting_mode = enabled
	cast_area.visible = enabled
	if enabled:
		change_state(PlayerState.CASTING)
	else:
		change_state(PlayerState.IDLE)

func change_state(new_state):
	if new_state == current_state:
		return

	# Exit current state
	match current_state:
		PlayerState.REELING:
			stop_reeling()

	current_state = new_state

	# Enter new state
	match current_state:
		PlayerState.CASTING:
			cast_area.visible = true
		PlayerState.REELING:
			start_reeling()
		_:
			cast_area.visible = false

func start_reeling():
	if not is_reeling:
		is_reeling = true
		reel_started.emit()
		print("Reeling started")

func stop_reeling():
	if is_reeling:
		is_reeling = false
		reel_ended.emit()
		print("Reeling ended")
