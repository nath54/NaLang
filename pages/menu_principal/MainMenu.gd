extends Control



func _on_bt_quitter_pressed() -> void:
	get_tree().quit();


func _on_bt_parametres_pressed() -> void:
	pass # Replace with function body.


func _on_bt_notions_importantes_pressed() -> void:
	get_tree().change_scene_to_file("res://pages/menu_principal/NotionsImportantes/NotionsImportantes.tscn");


func _on_bt_lexique_pressed() -> void:
	pass # Replace with function body.


func _on_bt_fiches_customs_pressed() -> void:
	get_tree().change_scene_to_file("res://pages/menu_principal/FichesCustom/ListeFiches.tscn");


func _on_bt_quiz_pressed() -> void:
	get_tree().change_scene_to_file("res://pages/menu_principal/Quiz/PrepareQuiz.tscn");
