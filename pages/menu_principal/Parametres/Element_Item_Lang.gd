extends Control
class_name Element_Item_Lang

var lang: String = "fr";

var is_ready: bool = false;

signal lang_selected(l: String);

func _ready():
	#
	is_ready = true;
	#
	%Label.text = Global.LANGUAGES_NAMES[lang];
	%TextureRect.texture = load("res://res/Flags/"+lang+".svg");


func set_lang(l: String) -> void:
	lang = l;
	if is_ready and %Label != null:
		%Label.text = Global.LANGUAGES_NAMES[lang];
	if is_ready and %TextureRect != null:
		%TextureRect.texture = load("res://res/Flags/"+lang+".svg");
	

func _on_select_button_pressed():
	emit_signal("lang_selected", lang);
