extends Control

signal next_day()

var slow_delay = 0.05
var fast_delay = 0.005
var delay = slow_delay

func show_lore(lore: Lore):
	$ContinueMarker.hide()
	show()
	$LoreText.visible_characters = 0
	delay = slow_delay

	# tidbits are just extra lines to integrate lore with ingame events
	var tidbits = []
	if $/root/Game/UI/Score.score > 300:
		tidbits.append("The bag is getting heavy but you press on.")

	# set new background
	for child in $/root/Game/Background.get_children():
		child.queue_free()
	$/root/Game/Background.add_child(lore.background.instantiate())

	var lore_text = lore.text
	if len(tidbits) > 0:
		lore_text += "\n\n" + tidbits[randi() % len(tidbits)]
		
	$LoreText.text = lore_text

	show_next_character()

func show_next_character():
	$LoreText.visible_characters += 1

	if $LoreText.visible_ratio >= 1:
		# fully shown, wait a couple of seconds and then show the continue mark
		var timer = get_tree().create_timer(1)
		timer.timeout.connect(func(): $ContinueMarker.show())
	else:	
		var timer = get_tree().create_timer(delay)
		timer.timeout.connect(show_next_character)	

func _input(event: InputEvent) -> void:
	if visible:
		if (event is InputEventKey and event.keycode == KEY_SPACE) or (event is InputEventMouseButton and event.pressed):
			if $LoreText.visible_ratio >= 1:
				hide()
				print("emitting next_day")
				emit_signal("next_day")
			else:
				skip_animation()

func skip_animation():
	print("skipping animation")
	delay = fast_delay
