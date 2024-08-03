extends Control


#
func _ready() -> void:
	display_discussion();

#
func display_discussion() -> void:
	# Nettoyage
	for children in %Elts_Container.get_children():
		children.queue_free();
	#
	var discussion_name_dst: String = Lib.get_discussion_nom(Global.ouverture_discussion, Global.current_lang_dst);
	var discussion_name_src: String = Lib.get_discussion_nom(Global.ouverture_discussion, Global.current_lang_src);
	#
	%Titre.text = discussion_name_dst + " - " + discussion_name_src;
	#
	var elts_discussion_lang_dst: Array = Lib.get_discussion_discussions(Global.ouverture_discussion, Global.current_lang_dst);
	var elts_discussion_lang_src: Array = Lib.get_discussion_discussions(Global.ouverture_discussion, Global.current_lang_src);
	#
	for i in range(len(elts_discussion_lang_dst)):
		#
		var elt_discussion: EltDiscussion = preload("res://pages/menu_principal/Discussions/Elt_Discussion.tscn").instantiate();
		#
		var text_lang_dst_: String = elts_discussion_lang_dst[i];
		var text_lang_src_: String = elts_discussion_lang_src[i];
		var color_: Color = Color("#b1dcfc");
		if i % 2 == 1:
			color_ = Color("#bae8b7");
		var align_: int = i % 2;
		#
		elt_discussion.set_text(text_lang_dst_, text_lang_src_, color_, align_);
		#
		%Elts_Container.add_child(elt_discussion);

#
func _on_bt_retour_pressed() -> void:
	get_tree().change_scene_to_file("res://pages/menu_principal/Discussions/ListeDiscussions.tscn");

