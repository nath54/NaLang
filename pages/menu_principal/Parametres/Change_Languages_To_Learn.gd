extends Control

const LANG_SELECTION_SRC: int = 0;
const LANG_SELECTION_DST: int = 1;

var lang_selection: int = LANG_SELECTION_DST;

# Called when the node enters the scene tree for the first time.
func _ready():
	#
	for lang in Global.LANGUAGES_NAMES.keys():
		#
		var lang_selection: Element_Item_Lang = preload("res://pages/menu_principal/Parametres/Element_Item_Lang.tscn").instantiate();
		lang_selection.set_lang(lang);
		lang_selection.lang_selected.connect(on_lang_selected);
		%Lang_Selection_Items.add_child(lang_selection);
		#
		print("Item select lang added : ", lang);
	#
	%Lang1.texture = load("res://res/Flags/"+Global.current_lang_src+".svg");
	%Lang2.texture = load("res://res/Flags/"+Global.current_lang_dst+".svg");



func on_lang_selected(lang: String):
	if lang_selection == LANG_SELECTION_SRC:
		Global.current_lang_src = lang;
		%Lang1.texture = load("res://res/Flags/"+lang+".svg");
	elif lang_selection == LANG_SELECTION_DST:
		Global.current_lang_dst = lang;
		%Lang2.texture = load("res://res/Flags/"+lang+".svg");
	#
	%PopUp_Select_Language.visible = false;


func _on_bt_lang_1_pressed():
	lang_selection = LANG_SELECTION_SRC;
	%PopUp_Select_Language.visible = true;

func _on_bt_lang_2_pressed():
	lang_selection = LANG_SELECTION_DST;
	%PopUp_Select_Language.visible = true;


func _on_bt_retour_pressed():
	get_tree().change_scene_to_file("res://pages/menu_principal/MainMenu.tscn");
