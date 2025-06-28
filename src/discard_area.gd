extends Area2D

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
	print("Updating item positions")
	var items = get_discarded_items()

	var rect = $CollisionShape2D.shape.size
	const padding = 10

	for i in range(len(items)):
		var angle = i * (360. / len(items))
		var radius = min(rect.x - padding * 2, rect.y - padding * 2) / 3

		var position_x = cos(deg_to_rad(angle)) * radius + padding
		var position_y = sin(deg_to_rad(angle)) * radius + padding

		items[i].target_position = global_position + Vector2(position_x, position_y)

func discard_items():
	for item in get_discarded_items():
		# Detach to avoid any race conditions
		reparent($/root)
		
		# Animate them offscreen instead of just having them disappear 
		item.target_position = item.global_position + Vector2(0, 1000)
		
		await get_tree().create_timer(0.5).timeout
		item.queue_free()
