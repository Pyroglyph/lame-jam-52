extends Sprite2D
class_name Cell

@export var is_item = false

var contains: Item = null

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_item and event is InputEventMouseButton and event.is_pressed():
		(get_parent() as Item).on_press(self)

func is_empty() -> bool:
	return contains == null
