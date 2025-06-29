extends Node2D

func _ready() -> void:
	get_tree().create_timer(2).timeout.connect(func(): get_tree().change_scene_to_file("res://scenes/game.tscn"))
