extends Node2D
class_name Cell

@export var is_item = false

var contains: Item = null

func _process(delta: float) -> void:
	if is_item:
		$Sprite2D.texture = null
		var tier = ""
		match (get_parent() as Item).tier:
			Tier.BRONZE:
				tier = "Bronze"
			Tier.SILVER:
				tier = "Silver"
			Tier.GOLD:
				tier = "Golden"
			Tier.MITHRIL:
				tier = "Mithril"
		$Collider.tooltip_text = tier + " " + (get_parent() as Item).item_name + " - " + str((get_parent() as Item).get_value())

func _on_gui_input(event: InputEvent) -> void:
	if is_item and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		(get_parent() as Item).on_press(self)
		get_viewport().set_input_as_handled()

func is_empty() -> bool:
	return contains == null
