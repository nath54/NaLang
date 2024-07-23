extends CenterContainer

var resbt = preload("res://pages/menu_principal/Quiz/BoutonAjoutFicheQuiz.tscn");

signal on_fiche_selected(fiche_path: String);

func _ready() -> void:
	#
	for fiche_path in Lib.get_fiches():
		#
		if not fiche_path in Global.quiz_selected_fiches:
			var bt: BoutonAjoutFicheQuiz = resbt.instantiate();
			bt.texte = Lib.get_fiche_nom(fiche_path);
			bt.fiche_path = fiche_path;
			bt.connect("on_ajout", _on_bt_pressed);
			#
			%FichesBtContainer.add_child(bt);

func _on_bt_pressed(fiche_path: String, bt_node: BoutonAjoutFicheQuiz):
	bt_node.queue_free();
	on_fiche_selected.emit(fiche_path);


func _on_bt_annuler_pressed():
	self.visible = false;

func on_deselected_fiche(fiche_path: String):
	var bt: BoutonAjoutFicheQuiz = resbt.instantiate();
	bt.texte = Lib.get_fiche_nom(fiche_path);
	bt.fiche_path = fiche_path;
	bt.connect("on_ajout", _on_bt_pressed);
	#
	%FichesBtContainer.add_child(bt);

