extends Node

# Où sont stockées les fiches "officielles"
const dir_fiches: String = "res://data/fiches/";
# Où sont stockées les fiches "custom"
const dir_custom_fiches: String = "user://custom_fiches_es/";

# Dans quel sens le quiz se fait
const QUIZ_SENS_DST_SRC: int = 0;
const QUIZ_SENS_SRC_DST: int = 1;
const QUIZ_SENS_BOTH: int = 2;

# Quel type de quiz c'est
const QUIZ_TYPE_CARTES: int = 0;
const QUIZ_TYPE_INPUT: int = 1;

#
var ouverture_fiche: String = "";
var ouverture_fiche_readonly: bool = true;

# Paramètres du quiz actuel
var quiz_selected_fiches: Array[String] = []; # list of "paths"
var quiz_sens: int = QUIZ_SENS_SRC_DST; 
var quiz_type: int = QUIZ_TYPE_CARTES;
var quiz_tot_questions: int = 10;
var quiz_score: float = 0;
var quiz_nb_current_questions: int = 0;
var quiz_all_elements: Array[Dictionary] = [];
var current_quiz_element: int = 0;
var current_quiz_question_sens: int = QUIZ_SENS_SRC_DST;
var current_quiz_allow_repetitions: bool = false;
var current_quiz_done_elements: Dictionary = {};
var current_quiz_availables_elements: Array[int] = [];

# Charger ici les fiches
const MAX_LOADED_FICHES: int = 100;
var loaded_fiches: Dictionary = {}; # "path" -> fiche dict
var fiches_uses: Dictionary = {}; # "path" -> Nb access

# Langues actuelles
var current_lang_src: String = "fr";
var current_lang_dst: String = "cn";

#
var rng: RandomNumberGenerator = RandomNumberGenerator.new();




