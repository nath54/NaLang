extends Button
class_name ButtonDirectory

@export var content_return_on_pressed: String = "";

var display_text: String = "";
var is_ready: bool = false;

signal bt_pressed(content: String);

func _on_pressed():
	print("bt dir pressed -> ", content_return_on_pressed);
	emit_signal("bt_pressed", content_return_on_pressed);

#
func _ready():
	is_ready = true;
	if display_text != "" and %Label != null:
		%Label.text = display_text;
	#
	pressed.connect(_on_pressed);

#
func set_display_text(txt: String):
	display_text = txt;
	if is_ready and %Label != null:
		%Label.text = display_text;
