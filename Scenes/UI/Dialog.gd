extends Control

var parent_node


signal skip_dialog_signal
onready var sfx = $sfx

var speaker

var dialog_wait_time =  2
var dialog
var current_dialog
var is_quest
var one_dialog_finished
var quest_time
onready var label = $ColorRect/RichTextLabel
onready var panel = $ColorRect
onready var main_panel = $ColorRect/ColorRect
onready var timer = $Timer
onready var progress_bar = $ColorRect/ColorRect/ProgressBar
var click_to_continue = false
var current_time = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	panel.visible = false
	if is_quest:
		main_panel.color = Color("fff8c3")
		progress_bar.visible = true
	else:
		main_panel.color = Color("d6ffc3")
	#label.bbcode_text = dialog["first"].content
	pass
	
func _process(delta):
	current_time+=delta
	#todo: ???  why need quest_time
	if progress_bar and is_quest and quest_time:
		progress_bar.value = current_time/quest_time
	
func init(_position, _dialog,_quest_params,dialog_size):
	dialog = _dialog
	rect_position = _position
	rect_size = dialog_size
	is_quest = _quest_params!=null
	if is_quest:
		quest_time = _quest_params.quest_time
	
func update_pivot():
	
	var pivot = current_dialog.get("pivot",[0,-1])
	var position_offset = Vector2(rect_size.x*pivot[0],rect_size.y*pivot[1])
	
	var rp = parent_node.get(current_dialog['speaker']).get_global_position()
	var origin_rect_position = rp
	origin_rect_position+=position_offset
	rect_position=origin_rect_position
	
func init_with_parent_node(_parent_node, _dialog,_is_quest, dialog_size = null):
	dialog = _dialog
	if dialog_size:
		rect_size = dialog_size
	parent_node = _parent_node
	is_quest = _is_quest
	current_dialog = dialog["first"]
	if current_dialog.has("speaker"):
		var speaker_name = current_dialog['speaker']
		speaker = parent_node.get(current_dialog['speaker'])
		var g_position = speaker.get_global_position()
		var rp = parent_node.get(current_dialog['speaker']).get_global_position()
		rect_position = parent_node.get(current_dialog['speaker']).get_global_position()
	click_to_continue = true
	
func start_dialog():
	current_dialog = dialog["first"]
#	if parent_node:
#		rect_position = parent_node.get(current_dialog['speaker']).get_global_position()
	yield(show_one_dialog(),"completed")
	
	
func show_one_dialog():
	
	yield(check_trigger(),"completed")
	yield(show_one_dialog_with_type_writing(),"completed")
#	label.bbcode_text = current_dialog.content
#	timer.wait_time = dialog_wait_time
#	timer.start()
#	yield(timer,"timeout")
	if click_to_continue and not DebugSetting.skip_dialog:
		
		yield(self,"skip_dialog_signal")
	
	yield(check_after_trigger(),"completed")
	yield(next(),"completed")

func next():
	if current_dialog.has("next"):
		current_dialog = dialog[current_dialog.next]
		yield(show_one_dialog(),"completed")
	else:
		yield(get_tree(), 'idle_frame')
	

#type writing
var wait_time : float = 0 if DebugSetting.skip_dialog else 0.03 # Time interval (in seconds) for the typewriter effect. Set to 0 to disable it. 
var pause_time : float = 0.4 # Duration of each pause when the typewriter effect is active.
var pause_char : String = '|' # The character used in the JSON file to define where pauses should be. If you change this you'll need to edit all your dialogue files.
var newline_char : String = '@' # The character used in the JSON file to break lines. If you change this you'll need to edit all your dialogue files.
var show_names : bool = true # Turn on and off the character name labels


var number_characters : = 0
var phrase = ''
var raw_text = '' #the raw phrase to show after remove pause and new line


var pause_index : = 0
var paused : = false
var pause_array : = []
var step


var typewriting_finished = true


#func clean(): # Resets some variables to prevent errors.
##	continue_indicator.hide()
##	animations.stop()
##	paused = false
##	pause_index = 0
##	pause_array = []
##	current_choice = 0
#	timer.wait_time = wait_time # Resets the typewriter effect delay

func clean_bbcode(string):
	phrase = string
	var pause_search = 0
	var line_search = 0
	
	pause_search = phrase.find('%s' % pause_char, pause_search)
	
	if pause_search >= 0:
		while pause_search != -1:
			phrase.erase(pause_search,1)
			pause_search = phrase.find('%s' % pause_char, pause_search)
	
	phrase = phrase.split('%s' % newline_char, true, 0) # Splits the phrase using the newline_char as separator
	
	var counter = 0
	label.bbcode_text = ''
	for n in phrase:
		label.bbcode_text = label.get('bbcode_text') + phrase[counter] + '\n'
		counter += 1

#func show_name(node, _name):
#	print("show name ",node.rect_position," ",_name)
#	node.get_node("label").text = _name
#	#node.rect_size.x = 0
#	node.set_process(true)
#	node.show()
#
#func hide_name(node):
#	node.hide()
#
#func check_names(block):
#	if not show_names:
#		return
#	if block.has('name'):
#		var talker_name = block['name']
#		Events.emit_signal("actor_talking",talker_name)
#		if block['position'] == 'left':
#			show_name(name_left,talker_name)
##			name_left.text = block['name']
##			yield(get_tree(), 'idle_frame')
##			name_left.rect_size.x = 0
##			#name_left.rect_position.x += name_offset.x
##			name_left.set_process(true)
##			name_left.show()
##			name_right.hide()
#		else:
#			show_name(name_right,talker_name)
#	else:
#		pass

func format_text(text):
	raw_text = text
	check_pauses()
	check_newlines(raw_text)
	clean_bbcode(text)
	number_characters = raw_text.length()

func check_pauses():
	#put all pause character into array and remove from raw_text
	var next_search = 0
	next_search = raw_text.find('%s' % pause_char, next_search)
	
	while next_search != -1:
		pause_array.append(next_search)
		raw_text.erase(next_search, 1)
		next_search = raw_text.find('%s' % pause_char, next_search)
			
func check_newlines(string):
	var line_search = 0
	var line_break_array = []
	var new_pause_array = []
	var current_line = 0
	raw_text = string
	line_search = raw_text.find('%s' % newline_char, line_search)
	
	if line_search >= 0:
		while line_search != -1:
			line_break_array.append(line_search)
			raw_text.erase(line_search,1)
			line_search = raw_text.find('%s' % newline_char, line_search)
	
		for a in pause_array.size():
			if pause_array[a] > line_break_array[current_line]:
				current_line += 1
			new_pause_array.append(pause_array[a]-current_line)
				
		pause_array = new_pause_array
		
func show_one_dialog_with_type_writing():
	yield(get_tree(), 'idle_frame')
	if parent_node and current_dialog.has("speaker"):
		var speaker_name = current_dialog['speaker']
		var speaker = parent_node.get(current_dialog['speaker'])
		var g_position = speaker.get_global_position()
		rect_position = parent_node.get(current_dialog['speaker']).get_global_position()
		update_pivot()
		#panel.rect_size = parent_node.get_dialog_size()
	#hide_name(name_left)
	#hide_name(name_right)
	
	panel.visible = true
	#clean()
	#current = step
	number_characters = 0 # Resets the counter
	# Check what kind of interaction the block is
#	match step['type']:
#		'text': # Simple text.
			#not_question()
	print("current_dialog0",current_dialog)
	if current_dialog.has("divert"):
		match current_dialog["condition"]:
			"boolean":
				var variable = current_dialog["variable"]
				var next
				if DialogUtil.call(variable):
					next = current_dialog["true"]
				else:
					next = current_dialog["false"]
				current_dialog = dialog[next]
				yield(show_one_dialog(),"completed")
	else:
		var text = current_dialog['content']
		if current_dialog.has("placeholder_value"):
			var placeholder_string_arr = current_dialog.placeholder_value
			var placeholder_value  = []
			for i in placeholder_string_arr:
				placeholder_value.append(DialogUtil.call(i))
			text = text%placeholder_value
		if dialog.has("placeholder_value"):
			text = text%dialog.placeholder_value
		#AutoCheckTranslation.addTranslation(text)
		#text = tr(text)
		format_text(text)
		#check_animation(step)
		#check_names(step)
	#		'action':
	#			rect_size.y = 0
	#			match step['operation']:
	#				'get_character':
	#					PartyManager.add_party_member(step['value'])
		
		if wait_time > 0: # Check if the typewriter effect is active and then starts the timer.
			label.visible_characters = 0
			start_typewriting()
			timer.wait_time = wait_time
			
			#timer.start()
			while label.visible_characters < number_characters:
				if paused:
					yield(update_pause(),"completed")
					 # If in pause, ignore the rest of the function.
	
				if pause_array.size() > 0: # Check if the phrase have any pauses left.
					if label.visible_characters == pause_array[pause_index]: # pause_char == index of the last character before pause.
						#timer.wait_time = pause_time #* wait_time * 10
						paused = true
					else:
						label.visible_characters += 1
				else: # Phrase doesn't have any pauses.
					label.visible_characters += 1
				
				timer.start()
				yield(timer,"timeout")
		stop_typewriting()
		if DebugSetting.skip_dialog:
			stop_typewriting()
			yield(get_tree(), 'idle_frame')
			return
		if not click_to_continue:
			timer.wait_time =dialog_wait_time
			timer.start()
			yield(timer,"timeout")
		yield(get_tree(), 'idle_frame')
	#	elif enable_continue_indicator: # If typewriter effect is disabled check if the ContinueIndicator should be displayed
	#		continue_indicator.show()
	#		animations.play('Continue_Indicator')

func check_trigger_common(trigger_type):
	if current_dialog.has(trigger_type):
		panel.visible = false
		label.bbcode_text = ''
		var trigger = current_dialog[trigger_type]
		yield(parent_node.trigger(trigger),"completed")
		panel.visible = true
	yield(get_tree(), 'idle_frame')

func check_trigger():
	yield(check_trigger_common("trigger"),"completed")
	
func check_after_trigger():
	yield(check_trigger_common("after_trigger"),"completed")


func skip_dialog():
	stop_typewriting()

func stop_typewriting():
	if typewriting_finished:
		emit_signal("skip_dialog_signal")
		return true
	finish_typewriting()
	label.visible_characters = number_characters
	return false
	
func finish_typewriting():
	sfx.stop()
	typewriting_finished = true
	
	if speaker and speaker.get("playing")!=null:
		speaker.playing = false
		speaker.frame = 0
	
func start_typewriting():
	sfx.play()
	typewriting_finished = false
	if speaker and speaker.get("playing")!=null:
		speaker.playing = true

func update_pause():
	if pause_array.size() > (pause_index+1): # Check if the current pause is not the last one. 
		pause_index += 1
	else: # Doesn't have any pauses left.
		pause_array = []
		pause_index = 0
		
	paused = false
	yield(get_tree().create_timer(pause_time), "timeout")
#	timer.wait_time = wait_time
#	timer.start()



func _on_Button_pressed():
	skip_dialog()
