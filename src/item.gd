extends Node2D
class_name Item

@export var item_name := "Item"
@export var base_value: int
@export_enum("Bronze", "Silver", "Gold", "Mithril") var tier: int = Tier.BRONZE

var is_grabbed := false
var grab_offset := Vector2.ZERO
var target_position := Vector2.ZERO
var original_position := Vector2.ZERO
var original_grid_cells = []

func get_value() -> int:
	var multiplier = 1 + (tier as float * 0.8)
	return int(floorf(base_value * multiplier))

var is_cell = func(c): return c is Cell
func get_grid_cells() -> Array[Cell]:
	var children = $/root/Game/Bag/Grid.get_children()
	var cells: Array[Cell]
	for child in children:
		if child is Cell:
			cells.append(child)
	return cells

# called by child cells
func on_press(_cell: Cell):
	print("grabbed " + item_name)

	is_grabbed = true
	z_index = 1000
	grab_offset = get_viewport().get_mouse_position() - global_position
	original_position = global_position.round()
	reparent($/root/Game, true)

	original_grid_cells = []
	# Iterate through grid cells and clear the reference if they contain this item
	for cell in get_grid_cells():
		# Check if the cell is a valid grid cell and contains this item
		if cell.contains == self:
			original_grid_cells.append(cell)
			cell.contains = null

func _process(_delta: float) -> void:
	if is_grabbed:
		# stick to mouse
		target_position = get_viewport().get_mouse_position() - grab_offset
	
	global_position = global_position.lerp(target_position, 0.2)

	match tier:
		Tier.BRONZE:
			$Sprite2DTint.modulate = Color(1, 0.5, 0)
		Tier.SILVER:
			$Sprite2DTint.modulate = Color(0.75, 0.75, 0.75)
		Tier.GOLD:
			$Sprite2DTint.modulate = Color(1, 1, 0)
		Tier.MITHRIL:
			$Sprite2DTint.modulate = Color(0.5, 0.15, 1.0)

func intersects_with(global_rect: Rect2) -> bool:
	# This only handles rectangles
	var intersects := false
	for cell: Cell in get_children().filter(is_cell):
		var cell_rect: Rect2 = (cell.get_node("Sprite2D") as Sprite2D).get_rect()
		# Transform the cell's local rectangle to global space
		cell_rect.position = cell.to_global(cell_rect.position)
		
		if cell_rect.intersects(global_rect):
			intersects = true
			break

	return intersects

func discard():
	# discard area automatically handles new children, so no need to fiddle with positioning
	reparent($/root/Game/DiscardArea)
	is_grabbed = false
	z_index = 0

func on_release():
	# first, determine if any of the cells are colliding with the discard area
	var discard_rect: Rect2 = $/root/Game/DiscardArea/CollisionShape2D.shape.get_rect()
	discard_rect.position = $/root/Game/DiscardArea.to_global(discard_rect.position)
	if intersects_with(discard_rect):
		Sound.play("res://assets/audio/cloth_impact.ogg")
		discard()
		return

	# if we're not discarding it, check if its on the grid properly
	print("Checking drop location")
	var grid_cells = get_grid_cells()
	var snap_target: Vector2 = Vector2.ZERO
	var valid_grid_cells = []
	var empty_cells := 0
	var mergable_cells := 0
	var merge_candidate: Item
	var cells = get_children().filter(is_cell)
	for cell in cells:
		for grid_cell: Cell in grid_cells:
			var grid_cell_rect: Rect2 = (grid_cell.get_node("Sprite2D") as Sprite2D).get_rect()
			# Transform the cell's local rectangle to global space
			grid_cell_rect.position = grid_cell.to_global(grid_cell_rect.position)
			if grid_cell_rect.has_point(cell.global_position.round()):
				if grid_cell.is_empty():
					empty_cells += 1
					valid_grid_cells.append(grid_cell)
					if cell.global_position.round() == global_position.round():
						snap_target = grid_cell.global_position.round()
					break
				else:
					var occupying_item: Item = grid_cell.contains
					if tier != Tier.GOLD and occupying_item.item_name == item_name and occupying_item.tier == tier:
						mergable_cells += 1
						merge_candidate = occupying_item
						valid_grid_cells.append(grid_cell)
						break

	var is_mergable = mergable_cells == len(cells)
	var valid_position = empty_cells == len(cells) or is_mergable

	if is_mergable:
		# all cells are mergable, so merge!
		merge_candidate.upgrade()

		# TODO: spawn some kind of particle effect before destroying this
		queue_free()
		return

	if valid_position:
		# all of this items cells fall within the bounds of the grid, and on empty cells
		print("released " + item_name)
		is_grabbed = false
		z_index = 0

		for cell in valid_grid_cells:
			cell.contains = self
		
		if snap_target != Vector2.ZERO:
			target_position = snap_target

		Sound.play("res://assets/audio/bag_place" + str(randi() % 2) + ".ogg")

		reparent($/root/Game/Bag, true)
	else:
		print("returning " + item_name + " to original position")
		if discard_rect.has_point(original_position):
			reparent($/root/Game/DiscardArea, true)
		else:
			target_position = original_position

		is_grabbed = false
		z_index = 0

		for cell in original_grid_cells:
			cell.contains = self
		original_grid_cells = []

		Sound.play("res://assets/audio/whoosh" + str(randi() % 3) + ".wav")


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released() and is_grabbed:
		print("trying to release " + item_name)
		on_release()

func get_center_offset() -> Vector2:
	var sprite: Sprite2D = get_node_or_null("Sprite2D")
	if not sprite:
		sprite = $Sprite2DTint

	# Calculate bounding box from texture size
	var size = sprite.texture.get_size()
	var origin = sprite.global_position
	if sprite.centered:
		origin -= size / 2.0

	var value = Rect2(origin, size).get_center() - global_position

	return value

func upgrade():
	tier += 1
	Sound.play("res://assets/audio/bag_place" + str(randi() % 2) + ".ogg")
	get_tree().create_timer(0.05).timeout.connect(func(): Sound.play("res://assets/audio/merge.ogg"))
	
