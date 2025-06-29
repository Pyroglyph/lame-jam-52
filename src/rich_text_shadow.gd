extends RichTextLabel

@export var source: RichTextLabel

func _process(_delta: float) -> void:
    text = source.text
    visible = source.visible
    visible_characters = source.visible_characters