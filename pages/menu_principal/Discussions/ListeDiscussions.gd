extends Control

const DATA_PATH: String = "res://data/discussions/";
@onready var ListeDiscussions = %ListeDiscussions;

var bt_node = preload("res://pages/menu_principal/Discussions/Bt_Discussion.tscn");

func _on_bt_retour_pressed() -> void:
	get_tree().change_scene_to_file("res://pages/menu_principal/MainMenu.tscn");

func add_discussion_button(d_name: String, d_path: String, readonly: bool) -> ButtonDiscussion:
	var mbt: ButtonDiscussion = bt_node.instantiate();
	mbt.texte = d_name;
	ListeDiscussions.add_child(mbt);
	#
	mbt.pressed.connect(click_discussion_bt.bind(d_path, readonly));
	#
	return mbt;


func click_discussion_bt(dp: String, readonly: bool) -> void:
	Global.ouverture_discussion = dp;
	get_tree().change_scene_to_file("res://pages/menu_principal/Discussions/Discussion.tscn");


func _ready() -> void:
	#
	for fp in Lib.list_files_in_directory(DATA_PATH):
		if fp.ends_with(".json"):
			#
			var langs: Array[String] = Lib.get_discussion_langs(fp);
			#
			if (Global.current_lang_src in langs) and (Global.current_lang_dst in langs):
				#
				add_discussion_button(Lib.get_discussion_nom(fp), fp, true);

