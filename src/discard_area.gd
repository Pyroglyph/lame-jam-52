extends Area2D

@onready var target_position: Vector2 = global_position
@onready var initial_position: Vector2 = Vector2(258.0, 113)

func get_discarded_items() -> Array[Item]:
	var items: Array[Item] = []
	for child in get_children():
		if child is Item:
			items.append(child)
	return items

func _notification(what: int) -> void:
	if what == NOTIFICATION_CHILD_ORDER_CHANGED:
		var items = get_discarded_items()
		if len(items) > 0:
			var newest_item: Item = items.pop_back()
			print(newest_item.item_name + " added to DiscardArea")
			update_item_positions()

# Distribute items evenly
func update_item_positions():
	var items := get_discarded_items()

	var rect = $CollisionShape2D.shape.size
	const padding = 10

	if len(items) == 1:
		var offset := items[0].get_center_offset()
		items[0].target_position = global_position - offset
		return

	for i in range(len(items)):
		var angle := i * (360. / len(items)) - 90
		var radius: float = min(rect.x - padding, rect.y - padding) / 3

		var position_x := cos(deg_to_rad(angle)) * radius
		var position_y := sin(deg_to_rad(angle)) * radius

		var offset := items[i].get_center_offset()
		items[i].target_position = global_position + Vector2(position_x, position_y) - offset

# If there are items to discard then it does so and returns true, if there are no items it returns false 
func discard_items() -> bool:
	# Get items before reparenting changes the children list
	var items_to_discard = get_discarded_items()
	if len(items_to_discard) == 0:
		return false

	for item in items_to_discard:
		# Detach to avoid any race conditions
		item.reparent($/root, true)
		item.queue_free()
	
	return true

func _process(_delta: float) -> void:
	global_position = global_position.lerp(target_position, 0.2)
	update_item_positions()

func begin_hiding():
	target_position = initial_position + Vector2(180, 0)

func begin_showing():
	show()
	target_position = initial_position