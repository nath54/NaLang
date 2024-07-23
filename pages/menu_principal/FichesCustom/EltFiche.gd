extends PanelContainer
class_name EltFiche

@export var words_1: Array = [];
@export var words_2: Array = [];
var readonly: bool = false;

var mot_node = preload("res://pages/menu_principal/FichesCustom/Mot.tscn");

func set_words_col(col: VBoxContainer, word_list: Array) -> void:
	# Cleaning
	for c in col.get_children():
		c.queue_free();
	# Colone
	col.add_child(Vide.new());
	for w in word_list:
		var mot: Mot = mot_node.instantiate();
		mot.mot = w;
		col.add_child(mot);
	col.add_child(Vide.new());


func _on_col_1_ready() -> void:
	set_words_col(%Col1, self.words_1);


func _on_col_2_ready() -> void:
	set_words_col(%Col2, self.words_2);


func _on_bt_edit_ready() -> void:
	if readonly:
		$Elt/Bts/Bt_edit.visible = false;


func _on_bt_supr_ready() -> void:
	if readonly:
		$Elt/Bts/Bt_supr.visible = false;
