extends Area2D

signal caught

var speed = 50
var direction = Vector2.ZERO
var bounds: Rect2
var bait_position: Vector2 = Vector2.ZERO
var is_attracted = false
var attraction_chance = 0.7
@onready var animsprite = $AnimatedSprite2D

func _ready():
	animsprite.play("swim")
	randomize()
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	body_entered.connect(_on_Fish_body_entered)
	
	bounds = get_viewport_rect()
	update_rotation()

func _process(delta):
	if is_attracted and bait_position != Vector2.ZERO:
		direction = (bait_position - position).normalized()
	
	var movement = direction * speed * delta
	position += movement
	
	if position.x < bounds.position.x or position.x > bounds.end.x:
		direction.x *= -1
	if position.y < bounds.position.y or position.y > bounds.end.y:
		direction.y *= -1
	
	update_rotation()

func update_rotation():
	var angle = direction.angle()
	animsprite.rotation = angle + PI/2

func _on_Fish_body_entered(body):
	if body.is_in_group("player"):
		caught.emit(self)

func attract_to_bait(bait_pos):
	if randf() < attraction_chance:
		is_attracted = true
		bait_position = bait_pos
	else:
		# Fish isn't attracted, choose a new random direction
		direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

func reset_attraction():
	is_attracted = false
	bait_position = Vector2.ZERO
