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
		# New items fly in from offscreen
		new_item.global_position = Vector2(400, $DiscardArea.global_position.y)

		# Add a 5% chance for an item to be rarer
		if randi() % 20 == 0:
			new_item.tier = Tier.SILVER
			
		$DiscardArea.add_child(new_item)

func next_quest():
	Sound.play("res://assets/audio/thump" + str(randi() % 3) + ".wav")
	if ($DiscardArea.discard_items()):
		var timer = get_tree().create_timer(0.2)
		timer.timeout.connect(give_new_items)
	else:
		give_new_items()
