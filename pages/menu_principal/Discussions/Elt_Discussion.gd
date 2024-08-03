extends HBoxContainer
class_name EltDiscussion

@export var text_lang_dst: String = "text";
@export var text_lang_src: String = "text";
@export var color: Color = Color("#ffffff");
@export var align: int = 0;  # 0 = align_left, 1 = align_right

var is_ready: bool = false;

#
func update_display() -> void:
	#
	if is_ready and %Label_lang_dst:
		%Label_lang_dst.text = text_lang_dst;
	if is_ready and %Label_lang_src:
		%Label_lang_src.text = text_lang_src;
	if is_ready and %Panel:
		%Panel.self_modulate = color;
	if is_ready:
		if align == 0:
			alignment = BoxContainer.ALIGNMENT_BEGIN;
		else:
			alignment = BoxContainer.ALIGNMENT_END;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_ready = true;
	update_display();


func set_text(text_lang_dst_: String, text_lang_src_: String, color_: Color, align_: int) -> void:
	text_lang_dst = text_lang_dst_;
	text_lang_src = text_lang_src_;
	color = color_;
	align = align_;
	#
	update_display();
