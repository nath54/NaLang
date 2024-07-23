extends Control



func _on_bt_conjugaison_pressed() -> void:
	get_tree().change_scene_to_file("res://pages/menu_principal/NotionsImportantes/Conjugaison/Conjugaisons.tscn");


func _on_bt_grammaire_pressed() -> void:
	pass # Replace with function body.


func _on_bt_nombres_pressed() -> void:
	pass # Replace with function body.


func _on_bt_retour_pressed() -> void:
	get_tree().change_scene_to_file("res://pages/menu_principal/MainMenu.tscn");
