extends Area2D

signal caught

enum FishState { WANDERING, ATTRACTED }

@export var speed = 50
@export var attraction_chance = 0.7
@export var attraction_range = 100

var current_state = FishState.WANDERING
var direction = Vector2.ZERO
var bounds: Rect2
var bait_position: Vector2 = Vector2.ZERO

@onready var animsprite = $AnimatedSprite2D

func _ready():
	animsprite.play("swim")
	randomize()
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	body_entered.connect(_on_Fish_body_entered)
	
	bounds = get_viewport_rect()
	update_rotation()

func _process(delta):
	match current_state:
		FishState.WANDERING:
			process_wandering(delta)
		FishState.ATTRACTED:
			process_attracted(delta)
	
	update_rotation()

func process_wandering(delta):
	var movement = direction * speed * delta
	position += movement
	
	if position.x < bounds.position.x or position.x > bounds.end.x:
		direction.x *= -1
	if position.y < bounds.position.y or position.y > bounds.end.y:
		direction.y *= -1

func process_attracted(delta):
	if bait_position == Vector2.ZERO:
		change_state(FishState.WANDERING)
		return
	
	var to_bait = bait_position - position
	if to_bait.length() <= attraction_range:
		var movement = to_bait.normalized() * speed * delta
		position += movement
	else:
		change_state(FishState.WANDERING)

func update_rotation():
	var angle = direction.angle()
	if current_state == FishState.ATTRACTED and bait_position != Vector2.ZERO:
		angle = (bait_position - position).angle()
	animsprite.rotation = angle + PI/2

func _on_Fish_body_entered(body):
	if body.is_in_group("player"):
		caught.emit(self)

func update_bait_position(new_bait_position):
	if new_bait_position == null:
		bait_position = Vector2.ZERO
		change_state(FishState.WANDERING)
	else:
		bait_position = new_bait_position
		check_attraction()

func check_attraction():
	if bait_position != Vector2.ZERO and position.distance_to(bait_position) <= attraction_range and randf() < attraction_chance:
		change_state(FishState.ATTRACTED)
	else:
		change_state(FishState.WANDERING)

func change_state(new_state):
	if new_state == current_state:
		return
	
	current_state = new_state
	
	match current_state:
		FishState.WANDERING:
			direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		FishState.ATTRACTED:
			# No specific initialization needed for attracted state
			pass
