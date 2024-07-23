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
		$ScrollContainer/CenterContainer/Container/HBoxContainer2/Titre.text = "Fiche : "+data["nom"];
		#
		for elt in data["elements"]:
			var wds1: Array = elt[0];
			var wds2: Array = elt[1];
			#
			var eltfiche: EltFiche = elt_node.instantiate();
			eltfiche.words_1 = wds1;
			eltfiche.words_2 = wds2;
			eltfiche.readonly = readonly;
			$ScrollContainer/CenterContainer/Container/Container.add_child(eltfiche);
		#
		if readonly:
			$ScrollContainer/CenterContainer/Container/HBoxContainer2/Bt_modif.visible = false;


func _on_bt_retour_pressed() -> void:
	get_tree().change_scene_to_file("res://pages/menu_principal/FichesCustom/ListeFiches.tscn");
