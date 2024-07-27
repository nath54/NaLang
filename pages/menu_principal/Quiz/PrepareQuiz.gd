extends Control

#
const OPTS_QUIZ_NB_QTS: Dictionary = {
	0: 5,
	1: 10,
	2: 20
};

#
var resbt = preload("res://pages/menu_principal/Quiz/BoutonAjoutFicheQuiz.tscn");

#
func _ready() -> void:
	#
	for sf in Global.quiz_selected_fiches:
		ajout_fiche_selection(sf)
	#
	%OptSens.set_item_text(0, Global.current_lang_src + " -> " + Global.current_lang_dst);
	%OptSens.set_item_text(1, Global.current_lang_dst + " -> " + Global.current_lang_src);
	#
	%OptSens.select(Global.quiz_sens);
	%OptType.select(Global.quiz_type);
	#
	var idx_opt_nb_qts: int = -1;
	#
	for idx_opt in OPTS_QUIZ_NB_QTS.keys():
		if OPTS_QUIZ_NB_QTS[idx_opt] == Global.quiz_tot_questions:
			idx_opt_nb_qts = idx_opt;
			break;
	#
	if idx_opt_nb_qts == -1:
		idx_opt_nb_qts = 1;
		Global.quiz_tot_questions = OPTS_QUIZ_NB_QTS[idx_opt_nb_qts];
	#
	%OptNbQts.select(idx_opt_nb_qts);

#
func _on_bt_retour_pressed() -> void:
	get_tree().change_scene_to_file("res://pages/menu_principal/MainMenu.tscn");

#
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

#
func enleve_fiche_selection(fiche_path: String, node: BoutonAjoutFicheQuiz) -> void:
	Global.quiz_selected_fiches.erase(fiche_path);
	node.queue_free();

#
func _on_opt_sens_item_selected(index) -> void:
	Global.quiz_sens = index;

#
func _on_opt_type_item_selected(index) -> void:
	Global.quiz_type = index;

#
func _on_bt_plus_pressed():
	%AjoutFicheMenu.visible = true;

#
func _on_ajout_fiche_menu_on_fiche_selected(fiche_path: String) -> void:
	ajout_fiche_selection(fiche_path);
	Global.quiz_selected_fiches.append(fiche_path);
	%AjoutFicheMenu.visible = false;

#
func _on_bouton_fiche_deselectionne(fiche_path: String, bt_node: BoutonAjoutFicheQuiz):
	bt_node.queue_free();
	%AjoutFicheMenu.on_deselected_fiche(fiche_path);
	Global.quiz_selected_fiches.erase(fiche_path);

#
func _on_bt_start_quiz_pressed():
	if len(Global.quiz_selected_fiches) == 0:
		%PopUpNoFicheSelected.visible = true;
		return;
	if Global.quiz_type == Global.QUIZ_TYPE_CARTES:
		get_tree().change_scene_to_file("res://pages/menu_principal/Quiz/Quiz_cartes.tscn");
	elif Global.quiz_type == Global.QUIZ_TYPE_INPUT:
		get_tree().change_scene_to_file("res://pages/menu_principal/Quiz/Quiz_ecrire.tscn");

#
func _on_bt_ok_pressed():
	%PopUpNoFicheSelected.visible = false;

#
func _on_opt_nb_qts_item_selected(index):
	Global.quiz_tot_questions = OPTS_QUIZ_NB_QTS[index];
