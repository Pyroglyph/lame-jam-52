extends Node2D

# dumb and stupid

@onready var target_position: Vector2 = global_position

func _process(_delta: float) -> void:
	global_position = global_position.lerp(target_position, 0.2)

func begin_hiding():
	target_position = global_position - Vector2(180, 0)

	for child: Cell in $/root/Game/Bag/Grid.get_children().filter(func(c): return c is Cell):
		if not child.is_empty():
			child.contains.can_move = false

func begin_showing():
	show()
	target_position = global_position + Vector2(180, 0)

	get_tree().create_timer(0.2).timeout.connect(
		func(): for child: Cell in $/root/Game/Bag/Grid.get_children().filter(func(c): return c is Cell):
			if not child.is_empty():
				child.contains.can_move = true
	)
