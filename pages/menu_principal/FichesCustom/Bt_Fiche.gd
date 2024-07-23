extends Button
class_name ButtonFiche

@export var texte = "";

func _on_label_ready() -> void:
	$HBoxContainer/Label.text = texte;

func _ready() -> void:
	focus_mode = FOCUS_NONE;
