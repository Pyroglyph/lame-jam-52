extends Node2D
class_name Item

@export var item_name := "Item"
@export var base_value: int
@export_enum("Bronze", "Silver", "Gold") var tier: int = Tier.BRONZE

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
	var children = $/root/Game/Grid.get_children()
	var cells: Array[Cell]
	for child in children:
		if child is Cell:
			cells.append(child)
	return cells

# called by child cells
func on_press(_cell: Cell):
	print("grabbed " + item_name)

	is_grabbed = true
	grab_offset = get_viewport().get_mouse_position() - global_position
	original_position = global_position.round()
	reparent($/root/Game)

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

	# null check is only required for development
	if $Sprite2D:
		match tier:
			Tier.BRONZE:
				$Sprite2D.modulate = Color(1, 0.5, 0) # Bronze color
			Tier.SILVER:
				$Sprite2D.modulate = Color(0.75, 0.75, 0.75) # Silver color
			Tier.GOLD:
				$Sprite2D.modulate = Color(1, 1, 0) # Gold color

func intersects_with(global_rect: Rect2) -> bool:
	# This only handles rectangles
	var intersects := false
	for cell: Cell in get_children().filter(is_cell):
		var cell_collision_shape: CollisionShape2D = cell.get_node("Area2D/CollisionShape2D")
		var cell_local_rect: Rect2 = cell_collision_shape.shape.get_rect()
		# Transform the cell's local rectangle to global space
		var cell_global_rect: Rect2 = cell_local_rect * cell.get_node("Area2D").global_transform

		if cell_global_rect.intersects(global_rect):
			intersects = true
			break

	return intersects

func on_release():
	# first, determine if any of the cells are colliding with the discard area
	var discard_local_rect = $/root/Game/DiscardArea/CollisionShape2D.shape.get_rect()
	var discard_global_rect = discard_local_rect * $/root/Game/DiscardArea.global_transform
	if intersects_with(discard_global_rect):
		print("Dropped on discard area")
		# discard area automatically handles new children
		reparent($/root/Game/DiscardArea)
		is_grabbed = false
		return

	# if we're not discarding it, check if its on the grid properly
	print("Checking drop location")
	var grid_cells = get_grid_cells()
	var valid_position = true
	var snap_target: Vector2 = Vector2.ZERO
	var valid_grid_cells = []
	for cell in get_children().filter(is_cell):
		var is_valid_cell = false
		for grid_cell in grid_cells:
			if grid_cell.is_empty():
				var collider: CollisionShape2D = grid_cell.get_node("Area2D/CollisionShape2D")
				if collider.shape is RectangleShape2D:
					var rect = Rect2(grid_cell.global_position.round() - collider.shape.size * 0.5, collider.shape.size)
					if rect.has_point(cell.global_position.round()):
						is_valid_cell = true
						valid_grid_cells.append(grid_cell)
						if cell.global_position.round() == global_position.round():
							snap_target = grid_cell.global_position.round()
						break
		if not is_valid_cell:
			valid_position = false
			break
	
	if valid_position:
		# all of this items cells fall within the bounds of the grid, and on empty cells
		print("released " + item_name)
		is_grabbed = false

		for cell in valid_grid_cells:
			cell.contains = self
		
		# for cell in original_grid_cells:
		# 	cell.contains = null

		if snap_target != Vector2.ZERO:
			target_position = snap_target
	else:
		print("returning " + item_name + " to original position")
		target_position = original_position
		is_grabbed = false

		for cell in original_grid_cells:
			cell.contains = self
		original_grid_cells = []


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released() and is_grabbed:
		print("trying to release " + item_name)
		on_release()
