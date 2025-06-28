extends Node2D

@export var common_items: Array[PackedScene] = []
@export var uncommon_items: Array[PackedScene] = []
@export var rare_items: Array[PackedScene] = []

var all_items: Array[Dictionary] = []


func _ready() -> void:
	# Combine all items into a single list with rarity weights
	for item in common_items:
		all_items.append({"scene": item, "chance": 6})
	for item in uncommon_items:
		all_items.append({"scene": item, "chance": 3})
	for item in rare_items:
		all_items.append({"scene": item, "chance": 1})
	
	give_new_items()

# Generates new items and places them into the discard area
func give_new_items():
	print("Generating items")
	var new_items: Array[PackedScene] = []

	# Pick items based on weighting
	for _i in range(randi_range(3, 4)):
		var total_chance = 0
		for item in all_items:
			total_chance += item.chance

		var random_value = randi_range(1, total_chance)
		var current_chance = 0
		for item in all_items:
			current_chance += item.chance
			if random_value <= current_chance:
				new_items.append(item.scene)
				break

	for item in new_items:
		var new_item = item.instantiate()

		# Add a 5% chance for an item to be rarer
		if randi() % 20 == 0:
			new_item.tier = Tier.SILVER
			
		$DiscardArea.add_child(new_item)

func next_quest():
	$DiscardArea.discard_items()

	give_new_items()
