extends Node2D

@export var speed := 100.0
@export var move_distance := -800.0
var moving := false
var done := false
var start_position: Vector2
var target_position: Vector2

func _ready() -> void:
	start_position = position
	target_position = start_position + Vector2(move_distance, 0)

func start_moving():
	moving = true

func _process(delta: float) -> void:
	if moving:
		position = position.move_toward(target_position, speed * delta)
		if position.distance_to(target_position) < 1.0:
			position = target_position
			moving = false
			done = true
	elif done:
		GameManager.end_game()
