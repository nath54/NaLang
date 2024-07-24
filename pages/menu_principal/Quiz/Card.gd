extends TextureButton
class_name QuizCard

var text_content: String = "";
var lang_content: String = "";
var is_ready: bool = false;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#
	is_ready = true;
	#
	if text_content != "" and %Label != null:
		%Label.text = text_content;
		%Lang.text = "("+lang_content+")";


#
func set_text_content(txt: String, lang: String) -> void:
	text_content = txt;
	lang_content = lang;
	if is_ready and %Label != null:
		%Label.text = text_content;
		%Lang.text = "("+lang_content+")";


