extends Control
class_name LoreOverlay

signal next_day()

var slow_delay = 0.04
var fast_delay = 0
var delay = slow_delay

var current_lore_is_final: bool = false

func show_lore(lore: Lore, is_final: bool = false):
	$ContinueMarker.hide()
	show()
	$Text.visible_characters = 0
	delay = slow_delay

	current_lore_is_final = is_final

	# set new background
	for child in $/root/Game/Background.get_children():
		child.queue_free()
	$/root/Game/Background.add_child(lore.background.instantiate())

	var lore_text = lore.text

	if not is_final:
		lore_text = with_tidbits(lore_text)
	else:
		lore_text = with_score(lore_text)

	$Text.text = lore_text

	show_next_character()

func with_tidbits(text: String) -> String:
	# disabled for now
	return text
	# tidbits are just extra lines to integrate lore with ingame events
	var tidbits = []
	if $/root/Game/UI/Score.score > 300:
		tidbits.append("The bag is getting heavy but you press on.")

	if len(tidbits) > 0:
		text += "\n\n" + tidbits[randi() % len(tidbits)]
	
	return text

func with_score(text: String) -> String:
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	var high_score = save_file.get_32()
	save_file.close()
	return text + "\n\n" + "Your bag is worth: " + str($/root/Game/UI/Score.score) + "\n" + "High score: " + str(high_score)

func show_next_character():
	$Text.visible_characters += 1

	if $Text.visible_ratio >= 1:
		if current_lore_is_final:
			$PlayAgainButton.show()
			$ExitButton.show()
		else:
			# fully shown, wait a couple of seconds and then show the continue mark
			var timer = get_tree().create_timer(1)
			timer.timeout.connect(func(): $ContinueMarker.show())
	else:	
		var timer = get_tree().create_timer(delay)
		timer.timeout.connect(show_next_character)

func _input(event: InputEvent) -> void:
	if visible:
		if (event is InputEventKey and event.is_pressed() and event.keycode == KEY_SPACE) or (event is InputEventMouseButton and event.is_released()):
			if $Text.visible_ratio >= 1:
				# there is no next day if this is the final one
				if not current_lore_is_final:
					hide()
					print("emitting next_day")
					emit_signal("next_day")
			else:
				skip_animation()

func skip_animation():
	print("skipping animation")
	delay = fast_delay

# seems weird to have these buttons in the lore viewer, but its convenient so ehhhh

func _on_exit_button_clicked() -> void:
	Sound.play("res://assets/audio/thump" + str(randi() % 3) + ".wav")
	get_tree().quit()

func _on_play_again_button_clicked() -> void:
	Sound.play("res://assets/audio/thump" + str(randi() % 3) + ".wav")
	$PlayAgainButton.hide()
	$ExitButton.hide()
	$/root/Game.restart()
