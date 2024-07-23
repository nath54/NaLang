extends Node

const dir_fiches: String = "res://data/fiches/";
const dir_custom_fiches: String = "user://custom_fiches_es/";

const QUIZ_SENS_FR_ESP: int = 0;
const QUIZ_SENS_ESP_FR: int = 1;
const QUIZ_SENS_BOTH: int = 2;

const QUIZ_TYPE_CARTES: int = 0;
const QUIZ_TYPE_INPUT: int = 1;

var ouverture_fiche: String = "";
var ouverture_fiche_readonly: bool = true;

var quiz_selected_fiches: Array[String] = []; # list of "paths"
var quiz_sens: int = QUIZ_SENS_FR_ESP; 
var quiz_type: int = QUIZ_TYPE_CARTES;

# Charger ici les fiches
const MAX_LOADED_FICHES: int = 100;
var loaded_fiches: Dictionary = {}; # "path" -> fiche dict
var fiches_uses: Dictionary = {}; # "path" -> Nb access
