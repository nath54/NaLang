extends Control

var fiche_path: String = "";
var readonly: bool = false;
var elt_node := preload("res://pages/menu_principal/FichesCustom/EltFiche.tscn");

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.ouverture_fiche != "":
		readonly = Global.ouverture_fiche_readonly;
		var data: Dictionary = Lib.load_file(Global.ouverture_fiche);
		Global.ouverture_fiche = "";
		#
		%Titre.text = "Fiche : "+data["name"][Global.current_lang_src];
		#
		for elt in data["elements"]:
			var wds1: Array = elt[Global.current_lang_src];
			var wds2: Array = elt[Global.current_lang_dst];
			#
			var eltfiche: EltFiche = elt_node.instantiate();
			eltfiche.words_1 = wds1;
			eltfiche.words_2 = wds2;
			eltfiche.readonly = readonly;
			%Elts_Container.add_child(eltfiche);
		#
		if readonly:
			%Bt_modif.visible = false;


func _on_bt_retour_pressed() -> void:
	get_tree().change_scene_to_file("res://pages/menu_principal/FichesCustom/ListeFiches.tscn");
