extends Node

func list_files_in_directory(path: String) -> Array[String]:
	var dir_elts: Array[String] = [];
	var dir: DirAccess = DirAccess.open(path);
	if dir == null:
		return [];
	#
	dir.list_dir_begin();
	#
	while true:
		var dir_elt: String = dir.get_next();
		if dir_elt == "":
			break
		elif not dir_elt.begins_with("."):
			dir_elts.append(path+dir_elt);
	#
	dir.list_dir_end();
	#
	return dir_elts;

#
func load_text_file(path: String) -> String:
	var txt: String = FileAccess.get_file_as_string(path);
	return txt;

#
func load_file(path: String) -> Dictionary:
	var txt: String = FileAccess.get_file_as_string(path);
	var data: Dictionary = JSON.parse_string(txt);
	return data;

# Retourne true si la fiche a bien été chargée
func charge_fiche(path: String) -> bool:
	if path in Global.loaded_fiches:
		return true;
	#
	if not FileAccess.file_exists(path):
		return false;
	#
	var fiche: Dictionary = load_file(path);
	#
	Global.loaded_fiches[path] = fiche;
	#
	return true;

func get_fiches() -> Array[String]:
	return list_files_in_directory(Global.dir_fiches)+list_files_in_directory(Global.dir_custom_fiches);

func get_fiche_nom(fiche_path: String) -> String:
	if fiche_path in Global.loaded_fiches:
		return Global.loaded_fiches[fiche_path]["nom"];
	#
	
	var fiche: Dictionary = load_file(fiche_path);
	#
	#Global.loaded_fiches[path] = fiche;
	#
	return fiche["nom"];


func get_fiche_data(fiche_path: String) -> Array:
	if fiche_path in Global.loaded_fiches:
		return Global.loaded_fiches[fiche_path]["data"];
	#
	
	var fiche: Dictionary = load_file(fiche_path);
	#
	#Global.loaded_fiches[path] = fiche;
	#
	return fiche["data"];

