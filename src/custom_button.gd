@tool
extends Control

signal clicked()

@export var text: String:
	get:
		return $Label.text
	set(new_text):
		$Label.text = new_text

@export var color: Color:
	get:
		return $ColorRect.color
	set(new_color):
		$ColorRect.color = new_color


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		emit_signal("clicked")
