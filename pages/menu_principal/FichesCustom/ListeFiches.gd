extends Control

const DATA_PATH: String = "res://data/fiches/";
@onready var ListeFiches = %ListeFiches;

var bt_node = preload("res://pages/menu_principal/FichesCustom/Bt_Fiche.tscn");

func _on_bt_retour_pressed() -> void:
	get_tree().change_scene_to_file("res://pages/menu_principal/MainMenu.tscn");

func add_fiche_button(f_name: String, f_path: String, readonly: bool) -> Button:
	var mbt: Button = bt_node.instantiate();
	mbt.texte = f_name;
	ListeFiches.add_child(mbt);
	#
	mbt.pressed.connect(click_fiche_bt.bind(f_path, readonly));
	#
	return mbt;


func click_fiche_bt(fp: String, readonly: bool) -> void:
	Global.ouverture_fiche = fp;
	Global.ouverture_fiche_readonly = readonly;
	get_tree().change_scene_to_file("res://pages/menu_principal/FichesCustom/Fiche.tscn");


func _ready() -> void:
	#
	for fp in Lib.list_files_in_directory(DATA_PATH):
		if fp.ends_with(".json"):
			#
			var langs: Array[String] = Lib.get_fiche_langs(fp);
			#
			if (Global.current_lang_src in langs) and (Global.current_lang_dst in langs):
				#
				add_fiche_button(Lib.get_fiche_nom(fp), fp, true);

