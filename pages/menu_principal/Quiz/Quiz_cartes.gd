extends Control


"""
Quiz states:
	0: non started
	1: started, card 1 displayed
	2: started, card 2 displayed
	3: started, result buttons displayed
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
	elif current_quiz_state == 2:
		current_quiz_state = 3;
	elif current_quiz_state == 3:
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
	if Global.current_quiz_question_sens == Global.QUIZ_SENS_SRC_DST:
		%Card1.set_text_content(txt_src, Global.current_lang_src);
		%Card2.set_text_content(txt_dst, Global.current_lang_dst);
	else:
		%Card2.set_text_content(txt_src, Global.current_lang_src);
		%Card1.set_text_content(txt_dst, Global.current_lang_dst);

#
func update_display() -> void:
	#
	%Quiz_State_0.visible = false;
	%Quiz_State_1.visible = false;
	%Quiz_State_2.visible = false;
	%Result.visible = false;
	#
	if current_quiz_state == 0:
		%Quiz_State_0.visible = true;
	elif current_quiz_state == 1:
		%Quiz_State_1.visible = true;
	elif current_quiz_state == 2:
		%Quiz_State_2.visible = true;
	elif current_quiz_state == 3:
		%Result.visible = true;

#
func _on_bt_stop_quiz_pressed() -> void:
	get_tree().change_scene_to_file("res://pages/menu_principal/Quiz/Quiz_result.tscn");

#
func _on_bt_0_pressed() -> void:
	Global.current_quiz_done_elements[Global.current_quiz_element] = 0;
	Global.quiz_score += 0.0;
	next_stage_quiz();

#
func _on_bt_5_pressed() -> void:
	Global.current_quiz_done_elements[Global.current_quiz_element] = 0.5;
	Global.quiz_score += 0.5;
	next_stage_quiz();

#
func _on_bt_10_pressed() -> void:
	Global.current_quiz_done_elements[Global.current_quiz_element] = 1.0;
	Global.quiz_score += 1.0;
	next_stage_quiz();

#
func _on_bt_start_quiz_pressed():
	#
	Lib.init_quiz_variables();
	#
	next_stage_quiz();
	#
	%Card1.pressed.connect(next_stage_quiz);
	%Card2.pressed.connect(next_stage_quiz);
