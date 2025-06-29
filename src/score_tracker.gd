extends Label

var score = 0

func _process(_delta: float):
	var total_score = 0
	var grid = $/root/Game/Bag/Grid
	var unique_items = {}

	for child: Cell in grid.get_children().filter(func (c): return c is Cell):
		if not child.is_empty():
			unique_items[child.contains] = true

	for item in unique_items.keys():
		total_score += item.get_value()

	score = total_score
	text = str(total_score)
