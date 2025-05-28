extends Area2D

@export var object_to_move: NodePath
var has_triggered := false

func _on_body_entered(body: Node) -> void:
	if body.name == "Player" and not has_triggered:
		has_triggered = true
		var target = get_node(object_to_move)
		if target:
			target.call("start_moving")
