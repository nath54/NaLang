extends Control

var current_path: PackedStringArray = [];
var current_file: String = "";

#
func _ready():
	update_display();

#
func on_directory_bt_pressed(directory_name: String):
	current_path.push_back(directory_name);
	update_display();

#
func on_file_bt_pressed(file_path: String):
	current_file = file_path;
	update_display();

#
func update_display():
	# Nettoyage
	%Directories_Files_Listing.visible = false;
	%TextContent.visible = false;
	# Affichage du chemin
	%Path.text = " / " + " / ".join(current_path);
	#
	for node in %Directories_Files_Listing.get_children():
		node.queue_free();
	#
	if current_file != "":
		%TextContent.text = Lib.load_text_file(current_file);
		%TextContent.visible = true;
		%TextContent.scroll_to_line(0);
	else:
		# On va lister tous les elements dans le dossier
		for dir_elt in Lib.list_files_in_directory("res://data/cours/"+Global.current_lang_src+"_"+Global.current_lang_dst+"/"+"/".join(current_path)+"/"):
			#
			var dir_elt_split: PackedStringArray = dir_elt.split("/");
			var dir_elt_name: String = dir_elt_split[len(dir_elt_split) - 1];
			#
			if dir_elt.ends_with(".txt"):
				var bt: ButtonFile = preload("res://pages/menu_principal/NotionsImportantes/ButtonFile.tscn").instantiate();
				bt.content_return_on_pressed = dir_elt;
				bt.set_display_text(dir_elt_name.substr(0, len(dir_elt_name) - 4).replace("_", " "));
				bt.bt_pressed.connect(on_file_bt_pressed);
				%Directories_Files_Listing.add_child(bt);
			elif not "." in dir_elt_name:
				var bt: ButtonDirectory = preload("res://pages/menu_principal/NotionsImportantes/ButtonDirectory.tscn").instantiate();
				bt.content_return_on_pressed = dir_elt_name;
				bt.set_display_text(dir_elt_name.replace("_", " "));
				bt.bt_pressed.connect(on_directory_bt_pressed);
				%Directories_Files_Listing.add_child(bt);
		%Directories_Files_Listing.visible = true;


#
func _on_bt_retour_pressed() -> void:
	if current_file != "":
		current_file = "";
		update_display();
	elif len(current_path) > 0:
		current_path.remove_at(len(current_path)-1);
		update_display();
	else:
		get_tree().change_scene_to_file("res://pages/menu_principal/MainMenu.tscn");
