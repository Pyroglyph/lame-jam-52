extends Node2D

@export var common_items: Array[PackedScene] = []
@export var uncommon_items: Array[PackedScene] = []
@export var rare_items: Array[PackedScene] = []

@export var lore: Array[Lore] = []
# @export var lore_backgrounds: Array[PackedScene] = []

var all_items: Array[Dictionary] = []

var day := 0

func _ready() -> void:
	# Combine all items into a single list with rarity weights
	for item in common_items:
		all_items.append({"scene": item, "chance": 6})
	for item in uncommon_items:
		all_items.append({"scene": item, "chance": 3})
	for item in rare_items:
		all_items.append({"scene": item, "chance": 1})

	show_next_lore()

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

	day += 1

	var time := 0.
	if (!$DiscardArea.discard_items()):
		time = 0.2

	var timer = get_tree().create_timer(time)
	timer.timeout.connect(show_next_lore)

func show_next_lore():
	Sound.play("res://assets/audio/bag_move.ogg")

	# temporary instant-hide, replace with sliding animation later
	$Bag.hide()
	$DiscardArea.hide()
	$UI.hide()

	if day == len(lore) - 1:
		# end of the game!

		# store highscore
		var score = $/root/Game/UI/Score.score
		# this stucks but i can't be bothered to make it better
		var high_score := 0
		if not FileAccess.file_exists("user://savegame.save"):
			var save_file := FileAccess.open("user://savegame.save", FileAccess.WRITE)
			save_file.store_32(score)
			save_file.close()
		else:
			var save_file := FileAccess.open("user://savegame.save", FileAccess.READ)
			high_score = save_file.get_32()
			save_file.close()
			if score > high_score:
				save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
				save_file.store_32(score)
			save_file.close()

		$LoreOverlay.show_lore(lore[day], true)
		return

	$LoreOverlay.show_lore(lore[day])

func show_next_day():
	Sound.play("res://assets/audio/bag_move.ogg")

	$LoreOverlay.hide()

	# TODO Change time of day / background - or maybe fade it in while the lore is showing?

	$Bag.show()
	$DiscardArea.show()
	$UI.show()

	give_new_items()
