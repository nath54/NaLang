extends Control


"""
Quiz states:
	0: non started
	1: started, question with input displayed
	2: started, answer with score displayed
"""
var current_quiz_state: int = 0;

#
func init_quiz_turn() -> bool:
	#
	Global.quiz_nb_current_questions += 1;
	if Global.quiz_nb_current_questions > Global.quiz_tot_questions:
		get_tree().change_scene_to_file("res://pages/menu_principal/Quiz/Quiz_result.tscn");
		return false;
	#
	current_quiz_state = 1;
	#
	if Global.quiz_sens == Global.QUIZ_SENS_DST_SRC:
		Global.current_quiz_question_sens = Global.QUIZ_SENS_DST_SRC;
	elif Global.quiz_sens == Global.QUIZ_SENS_SRC_DST:
		Global.current_quiz_question_sens = Global.QUIZ_SENS_SRC_DST;
	else:
		if Global.rng.randi_range(0, 1) == 0:
			Global.current_quiz_question_sens = Global.QUIZ_SENS_DST_SRC;
		else:
			Global.current_quiz_question_sens = Global.QUIZ_SENS_SRC_DST;
	#
	Global.current_quiz_element = Lib.select_quiz_next_question();
	#
	if Global.current_quiz_element == -1:
		get_tree().change_scene_to_file("res://pages/menu_principal/Quiz/Quiz_result.tscn");
		return false;
	#
	return true;

#
func next_stage_quiz() -> void:
	#
	if current_quiz_state == 0:
		if init_quiz_turn():
			init_quiz_display();
	elif current_quiz_state == 1:
		current_quiz_state = 2;
		#
		var user_input: String = %LineEdit.text;
		var user_input_traited: String = Lib.traite_txt(user_input);
		var score: float = 0.0;
		# Affichage de votre réponse
		%Label_Votre_Reponse.text = "Votre réponse était : %s" % [user_input];
		#
		var txt_src: String = "; ".join(PackedStringArray(Global.quiz_all_elements[Global.current_quiz_element][Global.current_lang_src]));
		var txt_dst: String = "; ".join(PackedStringArray(Global.quiz_all_elements[Global.current_quiz_element][Global.current_lang_dst]));
		#
		if Global.current_quiz_question_sens == Global.QUIZ_SENS_SRC_DST:
			# Calcul du score
			for sol in Global.quiz_all_elements[Global.current_quiz_element][Global.current_lang_dst]:
				var sol_score: float = 1.0 - Lib.normalized_levenshtein_distance(user_input_traited, Lib.traite_txt(sol));
				if sol_score > score:
					score = sol_score;
			# Affichage de la bonne réponse
			%Label_Reponse.text = "La traduction de %s (%s) en (%s) est : %s" % [txt_src, Global.current_lang_src, Global.current_lang_dst, txt_dst];
		else:
			# Calcul du score
			for sol in Global.quiz_all_elements[Global.current_quiz_element][Global.current_lang_dst]:
				var sol_score: float = 1.0 - Lib.normalized_levenshtein_distance(user_input_traited, Lib.traite_txt(sol));
				if sol_score > score:
					score = sol_score;
			# Affichage de la bonne réponse
			%Label_Reponse.text = "La traduction de %s (%s) en (%s) est : %s" % [txt_dst, Global.current_lang_dst, Global.current_lang_src, txt_src];
		# Affichage du score
		%Label_Score.text = "Score : %.1f" % [score];
		Global.quiz_score += score;
	#
	elif current_quiz_state == 2:
		if init_quiz_turn():
			init_quiz_display();
	#
	update_display();

#
func init_quiz_display() -> void:
	#
	var txt_src: String = "; ".join(PackedStringArray(Global.quiz_all_elements[Global.current_quiz_element][Global.current_lang_src]));
	var txt_dst: String = "; ".join(PackedStringArray(Global.quiz_all_elements[Global.current_quiz_element][Global.current_lang_dst]));
	#
	%LineEdit.text = "";
	if Global.current_quiz_question_sens == Global.QUIZ_SENS_SRC_DST:
		%Label_Question.text = "Veuillez traduire en %s: %s" % [Global.current_lang_src, txt_src];
	else:
		%Label_Question.text = "Veuillez traduire en %s: %s" % [Global.current_lang_dst, txt_dst];

#
func update_display() -> void:
	#
	%Quiz_State_0.visible = false;
	%Quiz_State_1.visible = false;
	%Quiz_State_2.visible = false;
	#
	if current_quiz_state == 0:
		%Quiz_State_0.visible = true;
	elif current_quiz_state == 1:
		%Quiz_State_1.visible = true;
	elif current_quiz_state == 2:
		%Quiz_State_2.visible = true;

#
func _on_bt_stop_quiz_pressed() -> void:
	get_tree().change_scene_to_file("res://pages/menu_principal/Quiz/Quiz_result.tscn");

#
func _on_bt_start_quiz_pressed():
	#
	Lib.init_quiz_variables();
	#
	next_stage_quiz();


func _on_bt_validate_pressed():
	next_stage_quiz();


func _on_bt_next_question_pressed():
	next_stage_quiz();
