extends Node

# Liste les fichiers et dossiers qui sont dans au path demandé
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

# On charge un fichier texte
func load_text_file(path: String) -> String:
	var txt: String = FileAccess.get_file_as_string(path);
	return txt;

# On charge un fichier json
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

# Réupère la liste des chemins des fiches
func get_fiches() -> Array[String]:
	return list_files_in_directory(Global.dir_fiches)+list_files_in_directory(Global.dir_custom_fiches);

# Réupère la liste des chemins des fiches disponibles pour le couple de langue sélectionné
func get_fiches_availables_for_theses_langs() -> Array[String]:
	#
	var result: Array[String] = [];
	#
	for fiche_path in get_fiches():
		#
		var fiche_lang: Array[String] = get_fiche_langs(fiche_path);
		#
		if (Global.current_lang_src in fiche_lang) and (Global.current_lang_dst in fiche_lang):
			result.append(fiche_path);
	#
	return result;

# Récupère le nom d'une fiche avec son path
func get_fiche_nom(fiche_path: String) -> String:
	# On s'assure que la fiche soit bien chargée
	charge_fiche(fiche_path);
	# On renvoie son nom
	if Global.current_lang_src in Global.loaded_fiches[fiche_path]["name"]:
		return Global.loaded_fiches[fiche_path]["name"][Global.current_lang_src];
	else:
		return Global.loaded_fiches[fiche_path]["name"][Global.loaded_fiches[fiche_path]["name"].keys()[0]];

# Récupère les langues d'une fiche avec son path
func get_fiche_langs(fiche_path: String) -> Array[String]:
	# On s'assure que la fiche soit bien chargée
	charge_fiche(fiche_path);
	# On renvoie son nom
	var langs: Array[String] = [];
	langs.assign(Global.loaded_fiches[fiche_path]["langs"]);
	return langs;

# Récupère les éléments d'une fiche avec son path
func get_fiche_elements(fiche_path: String) -> Array:
	# On s'assure que la fiche soit bien chargée
	charge_fiche(fiche_path);
	# On renvoie son data
	return Global.loaded_fiches[fiche_path]["elements"];

# Retourne true si la discussion a bien été chargée
func charge_discussion(path: String) -> bool:
	if path in Global.loaded_discussions:
		return true;
	#
	if not FileAccess.file_exists(path):
		return false;
	#
	var discussion: Dictionary = load_file(path);
	#
	Global.loaded_discussions[path] = discussion;
	#
	return true;

# Réupère la liste des chemins des fiches
func get_discussions() -> Array[String]:
	return list_files_in_directory(Global.dir_discussions);

# Réupère la liste des chemins des fiches disponibles pour le couple de langue sélectionné
func get_discussions_availables_for_theses_langs() -> Array[String]:
	#
	var result: Array[String] = [];
	#
	for path in get_fiches():
		#
		var discussion_langs: Array[String] = get_discussion_langs(path);
		#
		if (Global.current_lang_src in discussion_langs) and (Global.current_lang_dst in discussion_langs):
			result.append(path);
	#
	return result;

# Récupère le nom d'une fiche avec son path
func get_discussion_nom(path: String, lang: String = Global.current_lang_src) -> String:
	# On s'assure que la fiche soit bien chargée
	charge_discussion(path);
	# On renvoie son nom
	if lang in Global.loaded_discussions[path]["name"]:
		return Global.loaded_discussions[path]["name"][lang];
	else:
		return Global.loaded_discussions[path]["name"][Global.loaded_discussions[path]["name"].keys()[0]];

# Récupère les langues d'une fiche avec son path
func get_discussion_langs(path: String) -> Array[String]:
	# On s'assure que la fiche soit bien chargée
	charge_discussion(path);
	# On renvoie son nom
	var langs: Array[String] = [];
	langs.assign(Global.loaded_discussions[path]["langs"]);
	return langs;

# Récupère les éléments d'une fiche avec son path
func get_discussion_discussions(path: String, lang: String) -> Array:
	# On s'assure que la fiche soit bien chargée
	charge_discussion(path);
	# On renvoie son data
	return Global.loaded_discussions[path]["discussion"][lang];

# Function to calculate the Levenshtein distance between two strings
func levenshtein_distance(str1: String, str2: String) -> int:
	#
	var len1: int = str1.length()
	var len2: int = str2.length()

	#
	if len1 == 0:
		return len2
	if len2 == 0:
		return len1

	#
	var matrix: Array = [];
	
	# Initialize the matrix
	for i in range(len1 + 1):
		matrix.append([i])
	#
	for j in range(1, len2 + 1):
		matrix[0].append(j)

	#
	var cost: int;

	# Populate the matrix
	for i in range(1, len1 + 1):
		for j in range(1, len2 + 1):
			#
			if str1[i - 1] == str2[j - 1]:
				cost = 0;
			else:
				cost = 1;
			#
			matrix[i].append(min(matrix[i - 1][j] + 1,      # Deletion
								 matrix[i][j - 1] + 1,      # Insertion
								 matrix[i - 1][j - 1] + cost))  # Substitution
	return matrix[len1][len2];

# Returns a value between 0 and 1, normalized by the 
func normalized_levenshtein_distance(str1: String, str2: String) -> float:
	#
	var len1: int = len(str1);
	var len2: int = len(str2);

	#
	if len1 == 0 or len2 == 0:
		return 1.0;

	#
	return float(levenshtein_distance(str1, str2)) / float(max(len1, len2));

#
const traite_txt_chars_replacement: Dictionary = {
	"á": "a",
	"à": "a",
	"ȧ": "a",
	"â": "a",
	"ä": "a",
	"ǎ": "a",
	"ă": "a",
	"ā": "a",
	"ḃ": "b",
	"ƀ": "b",
	"ɓ": "b",
	"ḅ": "b",
	"ḇ": "b",
	"ć": "c",
	"ċ": "c",
	"ĉ": "c",
	"č": "c",
	"ç": "c",
	"ȼ": "c",
	"ḉ": "c",
	"ḋ": "d",
	"ď": "d",
	"ḑ": "d",
	"đ": "d",
	"ƌ": "d",
	"ɗ": "d",
	"ḍ": "d",
	"ḓ": "d",
	"ḏ": "d",
	"é": "e",
	"è": "e",
	"ė": "e",
	"ê": "e",
	"ë": "e",
	"ě": "e",
	"ĕ": "e",
	"ē": "e",
	"ẽ": "e",
	"ę": "e",
	"ȩ": "e",
	"ɇ": "e",
	"ế": "e",
	"ề": "e",
	"ḗ": "e",
	"ḕ": "e",
	"ễ": "e",
	"ḝ": "e",
	"ḟ": "f",
	"ƒ": "f",
	"ǵ": "g",
	"ġ": "g",
	"ĝ": "g",
	"ǧ": "g",
	"ğ": "g",
	"ḡ": "g",
	"ģ": "g",
	"ǥ": "g",
	"ḣ": "h",
	"ĥ": "h",
	"ḧ": "h",
	"ȟ": "h",
	"ḩ": "h",
	"ħ": "h",
	"ḥ": "h",
	"ḫ": "h",
	"ⱨ": "h",
	"í": "i",
	"ì": "i",
	"ı": "i",
	"î": "i",
	"ï": "i",
	"ǐ": "i",
	"ĭ": "i",
	"ī": "i",
	"ĩ": "i",
	"į": "i",
	"ɨ": "i",
	"ḯ": "i",
	"ỉ": "i",
	"ĵ": "j",
	"ǰ": "j",
	"ḱ": "k",
	"ǩ": "k",
	"ķ": "k",
	"ƙ": "k",
	"ḳ": "k",
	"ĺ": "l",
	"ŀ": "l",
	"ľ": "l",
	"ⱡ": "l",
	"ļ": "l",
	"ƚ": "l",
	"ł": "l",
	"ḷ": "l",
	"ḽ": "l",
	"ḿ": "m",
	"ṁ": "m",
	"ṃ": "m",
	"ń": "n",
	"ǹ": "n",
	"ṅ": "n",
	"ň": "n",
	"ñ": "n",
	"ņ": "n",
	"ɲ": "n",
	"ƞ": "n",
	"ṇ": "n",
	"ṋ": "n",
	"ó": "o",
	"ò": "o",
	"ȯ": "o",
	"ô": "o",
	"ö": "o",
	"ǒ": "o",
	"ŏ": "o",
	"ō": "o",
	"õ": "o",
	"ǫ": "o",
	"ő": "o",
	"ố": "o",
	"ồ": "o",
	"ø": "o",
	"ṓ": "o",
	"ṑ": "o",
	"ȱ": "o",
	"ṍ": "o",
	"ṕ": "p",
	"ṗ": "p",
	"ᵽ": "p",
	"ƥ": "p",
	"q": "q",
	"ŕ": "r",
	"ṙ": "r",
	"ř": "r",
	"ŗ": "r",
	"ɍ": "r",
	"ɽ": "r",
	"ȑ": "r",
	"ȓ": "r",
	"ṛ": "r",
	"ś": "s",
	"ṡ": "s",
	"ŝ": "s",
	"š": "s",
	"ş": "s",
	"ṥ": "s",
	"ṧ": "s",
	"ṣ": "s",
	"ș": "s",
	"ṫ": "t",
	"ẗ": "t",
	"ť": "t",
	"ţ": "t",
	"ƭ": "t",
	"ṭ": "t",
	"ʈ": "t",
	"ț": "t",
	"ṱ": "t",
	"ṯ": "t",
	"ⱦ": "t",
	"ú": "u",
	"ù": "u",
	"û": "u",
	"ü": "u",
	"ǔ": "u",
	"ŭ": "u",
	"ū": "u",
	"ũ": "u",
	"ů": "u",
	"ų": "u",
	"ű": "u",
	"ʉ": "u",
	"ǘ": "u",
	"ǜ": "u",
	"ǚ": "u",
	"ṹ": "u",
	"ǖ": "u",
	"ṻ": "u",
	"ủ": "u",
	"ȕ": "u",
	"ȗ": "u",
	"ư": "u",
	"ṽ": "v",
	"ṿ": "v",
	"ʋ": "v",
	"ẃ": "w",
	"ẁ": "w",
	"ẇ": "w",
	"ŵ": "w",
	"ẅ": "w",
	"ẘ": "w",
	"ẋ": "x",
	"ẍ": "x",
	"ý": "y",
	"ỳ": "y",
	"ẏ": "y",
	"ŷ": "y",
	"ÿ": "y",
	"ȳ": "y",
	"ỹ": "y",
	"ẙ": "y",
	"ɏ": "y",
	"ỷ": "y",
	"ź": "z",
	"ż": "z",
	"ẑ": "z",
	"ž": "z",
	"ƶ": "z",
	"ȥ": "z",
	"ẓ": "z"
};

const traite_txt_chars_to_remove: String = " ,?;.:/!§*µ%$£^<>&~\"'{}()[]-|`_\\^@°=+€0123456789";

#
func traite_txt(str: String) -> String:
	str = str.to_lower();
	#
	for l in traite_txt_chars_replacement.keys():
		str = str.replace(l, traite_txt_chars_replacement[l]);
	#
	for l in traite_txt_chars_to_remove:
		str = str.replace(l, "");
	#
	return str;

# Pas d'éléments suivant si retourne -1
func select_quiz_next_question() -> int:
	if Global.current_quiz_allow_repetitions:
		return Global.rng.randi_range(0, len(Global.current_quiz_done_elements)-1);
	else:
		if len(Global.current_quiz_availables_elements) == 0:
			return -1;
		#
		var idx: int = Global.rng.randi_range(0, len(Global.current_quiz_availables_elements)-1);
		#
		return Global.current_quiz_availables_elements.pop_at(idx);;

#
func init_quiz_variables() -> void:
	# On va charger tous les éléments de toutes les fiches sélectionnées
	Global.quiz_all_elements = [];
	for fp in Global.quiz_selected_fiches:
		Global.quiz_all_elements.append_array(Lib.get_fiche_elements(fp));
	#
	if not Global.current_quiz_allow_repetitions:
		Global.current_quiz_availables_elements = [];
		Global.current_quiz_availables_elements.append_array(range(len(Global.quiz_all_elements)));
	#
	Global.current_quiz_element = -1;
	Global.quiz_nb_current_questions = 0;
	Global.quiz_score = 0;
	Global.current_quiz_done_elements = {};
