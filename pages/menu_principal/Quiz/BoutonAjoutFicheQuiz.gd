extends PanelContainer
class_name BoutonAjoutFicheQuiz

@export var texte = "";
@export var fiche_path = "";
var bt_texte = "ajouter";

signal on_ajout(fiche_path: String, node: BoutonAjoutFicheQuiz);


func _on_label_ready() -> void:
	$MarginContainer/HBoxContainer/Label.text = texte;

func _on_button_ready():
	$MarginContainer/HBoxContainer/Button.text = bt_texte;

func _on_button_pressed() -> void:
	on_ajout.emit(self.fiche_path, self);


