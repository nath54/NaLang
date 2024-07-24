extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	%Label_Score.text = "Score : %1.1f / %d" % [Global.quiz_score, Global.quiz_nb_current_questions];
	#
	var ratio: float = Global.quiz_score / float(Global.quiz_nb_current_questions);
	#
	if ratio >= 1.0:
		%Label_Commentaire.text = "Score parfait, Bravo !";
	elif ratio >= 0.8:
		%Label_Commentaire.text = "Presque à la perfection, encore un tout petit effort !";
	elif ratio >= 0.6:
		%Label_Commentaire.text = "Un bon score, on continue comme ça !";
	elif ratio >= 0.5:
		%Label_Commentaire.text = "Plus de la moitié, allez, courage !";
	elif ratio >= 0.3:
		%Label_Commentaire.text = "Mauvais score, il faut travailler !";
	else:
		%Label_Commentaire.text = "Très mauvais score, il faut commencer à travailler !";

#
func _on_bt_quit_quiz_pressed():
	get_tree().change_scene_to_file("res://pages/menu_principal/MainMenu.tscn");

#
func _on_bt_redo_quiz_pressed():
	if Global.quiz_type == Global.QUIZ_TYPE_CARTES:
		get_tree().change_scene_to_file("res://pages/menu_principal/Quiz/Quiz_cartes.tscn");
	elif Global.quiz_type == Global.QUIZ_TYPE_INPUT:
		get_tree().change_scene_to_file("res://pages/menu_principal/Quiz/Quiz_ecrire.tscn");
