extends Control

var resbt = preload("res://pages/menu_principal/Quiz/BoutonAjoutFicheQuiz.tscn");

func _ready() -> void:
	#
	#for fiche in Lib.get_fiches():
	#	if not fiche in Global.loaded_fiches:
	#		Lib.charge_fiche(Global.dir_fiches + fiche);
		#
		
	#
	for sf in Global.quiz_selected_fiches:
		ajout_fiche_selection(sf)
	#
	%OptSens.select(Global.quiz_sens);
	%OptType.select(Global.quiz_type);


func _on_bt_retour_pressed() -> void:
	get_tree().change_scene_to_file("res://pages/menu_principal/MainMenu.tscn");


func ajout_fiche_selection(fiche_path: String) -> void:
	if not fiche_path in Global.loaded_fiches:
		Lib.charge_fiche(fiche_path);
	#
	var btf: BoutonAjoutFicheQuiz = resbt.instantiate();
	btf.texte = Lib.get_fiche_nom(fiche_path);
	btf.bt_texte = "enlever";
	btf.fiche_path = fiche_path;
	btf.connect("on_ajout", _on_bouton_fiche_deselectionne);
	%FicheBtSelecContainer.add_child(btf);

func enleve_fiche_selection(fiche_path: String, node: BoutonAjoutFicheQuiz) -> void:
	Global.quiz_selected_fiches.erase(fiche_path);
	node.queue_free();


func _on_opt_sens_item_selected(index) -> void:
	Global.quiz_sens = index;

func _on_opt_type_item_selected(index) -> void:
	Global.quiz_type = index;


func _on_bt_plus_pressed():
	%AjoutFicheMenu.visible = true;


func _on_ajout_fiche_menu_on_fiche_selected(fiche_path: String) -> void:
	ajout_fiche_selection(fiche_path);
	Global.quiz_selected_fiches.append(fiche_path);
	%AjoutFicheMenu.visible = false;

func _on_bouton_fiche_deselectionne(fiche_path: String, bt_node: BoutonAjoutFicheQuiz):
	bt_node.queue_free();
	%AjoutFicheMenu.on_deselected_fiche(fiche_path);
	Global.quiz_selected_fiches.erase(fiche_path);
