extends Node2D


var moon_scene = preload("res://Scenes/game2/Object/Moon.tscn")
var generator_scene = preload("res://Scenes/game2/Object/Generator.tscn")
var platformer_scene = preload("res://Scenes/game2/Object/platformer.tscn")
onready var hint_label = $Camera2D/Node2D/Control/hint
var level_name_flyaway_time = 0
var current_human

var advertisement = preload("res://Scenes/UI/advertisement.tscn")
var advertisement_instance
var Moon
var Generator
onready var human = $human
onready var bullets = $bullets
onready var timer = $Timer
var dialog_folder = "res://resources/dialog"

var dialog_instance 
var dialog_state = -1 #-1 prolog, 0 pre level, 1 end level

var generator_instance
var can_input = true
var can_generate_player = true

var move_dir = Vector2.RIGHT

var index_to_human_map ={}

var index_to_passthrough_map ={}

onready var level_name = $Camera2D/Node2D/Control/level_name
#var human_to_index_map ={}

#dialog
onready var Leader = $Leader


func thunder_on_column(index_position):
	for i in range(Utils.height_offset,Utils.height_offset+Utils.height_index):
		var check_position = Vector2(index_position.x,i)
		if has_occupied(check_position):
			var human = index_to_human_map.get(check_position)
			if human.can_block_thunder() and human.is_stoping:
				human.block_thunder()
				return
			else:
				human.die()
		if can_passthrough(check_position):
			remove_passthrough(check_position)
	
	
	
func find_blocker_on_thunder(index_position):
	pass

func has_column_occupied(index_position):
	for i in range(Utils.height_offset,Utils.height_offset+Utils.height_index):
		if has_occupied(Vector2(index_position.x,i)):
			return true
	return false
	
func column_occupied_count(index_position):
	var res = 0
	for i in range(Utils.height_offset,Utils.height_offset+Utils.height_index):
		if has_occupied(Vector2(index_position.x,i)):
			res+=1
	return res
	
func kick_highest(index_position):
	var highest = get_highest_in_column(index_position)
	if highest:
		var human = index_to_human_map.get(highest)
		if human:
			human.die()
	
func get_highest_in_column(index_position):
	for i in range(Utils.height_offset,Utils.height_offset+Utils.height_index):
		if has_occupied(Vector2(index_position.x,i)):
			return Vector2(index_position.x,i)
	return null

func change_occupy(old_index_position,new_index_position,human):
	
	if not Utils.in_game_screen(new_index_position) :
		index_to_human_map.erase(old_index_position)
		return
	
	if not index_to_human_map.has(old_index_position) :
		#printerr("in change occupy, human does not exist in %s"%String(old_index_position))
		pass
	if index_to_human_map.has(new_index_position) :
		printerr("human do exist in %s"%String(new_index_position))
		return
	#var human = index_to_human_map.get(old_index_position)
	index_to_human_map.erase(old_index_position)
	index_to_human_map[new_index_position] = human
	human.index = new_index_position
	#print("changed occupy ",index_to_human_map, old_index_position, new_index_position)
	

func remove_occupy(index_position):
	if not index_to_human_map.has(index_position) :
		printerr("in remove, human does not exist in %s"%String(index_position))
	var human = index_to_human_map.get(index_position)
	if human:
		human.will_free()
	else:
		printerr("why no human here??",index_to_human_map, index_position ) 
	index_to_human_map.erase(index_position)
	


func add_passthrough(index_position):
	#print("add passthrough ",index_position)
	index_to_passthrough_map[index_position] = true
	
func remove_passthrough(index_position):
	index_to_passthrough_map.erase(index_position)

func can_passthrough(index_position):
	#print("can_passthrough ",index_position)
	return index_to_passthrough_map.has(index_position) 

func has_occupied(index_position):
	#print("has occupied ",index_to_human_map,index_position)
	return index_to_human_map.has(index_position) 

func get_above_human_if_existed(human):
	var current_index = human.index_position()
	var above_index = current_index+Vector2.UP
	if has_occupied(above_index):
		return index_to_human_map[above_index]
	return human


func on_touched_tile(index):
	#print(index)
#	var human_instance = human_scene.instance()
#	human_instance.position = Utils.index_to_position(Vector2(index.x,Utils.height_index-1))
#	human.add_child(human_instance)
	pass
	
func on_touched_shot(index):
	return
	#print(index)
#	if has_column_occupied(index):
#		var index_position = get_highest_in_column(index)
#		var human_instance = shot_scene.instance()
#		human_instance.position = Utils.index_to_position(index_position)
#		human.add_child(human_instance)



func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_SPACE or event.scancode == KEY_ENTER:
			if dialog_instance:
				dialog_instance.skip_dialog()
		#if event.scancode != KEY_ENTER:
			#Do what you gotta do.
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and  event.is_pressed():
		#print("Mouse Click/Unclick at: ", event.position)
		kick_highest(Utils.position_to_index(event.position))
	if not can_input:
		return
		

# Called when the node enters the scene tree for the first time.
func _ready():
	level_name.text = ""
	#timer.wait_time = Utils.wait_time*4
	Utils.maingame = self
	
	Utils.update_game_level()
	
	Moon = moon_scene.instance()
	add_child(Moon)
	
	Events.connect("player_stopped", self, "on_player_stopped")
	
	if LevelManager.is_prolog():
		show_prolog()
	else:
		Utils.update_game_level()
		init_generator_and_platformer()
		show_level_start_dialog()
		Leader.visible = false
	

	
func on_player_stopped():
	can_generate_player = true

func show_prolog():
	var file_path = '%s/%s.json' % [dialog_folder, "prolog"]
	var prolog = Utils.load_json(file_path)
	dialog_instance = DialogManager.select_dialog_multiple(self,prolog)
	yield(get_tree(), 'idle_frame')
	add_child(dialog_instance)
	Leader.visible = true
	dialog_state = -1
	dialog_instance.start_dialog()

func show_level_start_dialog():
	yield(show_level_name(),"completed")
	
	#yield(get_tree().create_timer(1), "timeout")
	var file_path = '%s/%s%d.json' % [dialog_folder, "level",LevelManager.current_level]
	var prolog = Utils.load_json(file_path)
	dialog_instance = DialogManager.select_dialog_multiple(self,prolog)
	yield(get_tree(), 'idle_frame')
	add_child(dialog_instance)
	dialog_state = 0
	dialog_instance.start_dialog()

func show_level_end_dialog():
	var file_path = '%s/%s%d%s.json' % [dialog_folder, "level",LevelManager.current_level,"_end"]
	var prolog = Utils.load_json(file_path)
	dialog_instance = DialogManager.select_dialog_multiple(self,prolog)
	yield(get_tree(), 'idle_frame')
	add_child(dialog_instance)
	dialog_state = 1
	dialog_instance.start_dialog()

func show_level_name():
	
	var level_name_exist_time = 0.1 if DebugSetting.skip_dialog else 2
	var level_name_fly_away_time = 0.1 if DebugSetting.skip_dialog else 1.5
	var text  = LevelManager.get_level_info().name
	level_name.bbcode_text = "\n\n\n\n[center][wave]"+text
	yield(get_tree().create_timer(level_name_exist_time), "timeout")
	
	var tween = Tween.new()

	add_child(tween)
	tween.interpolate_property(
				self, 
				"level_name_flyaway_time", 
				0,800, level_name_fly_away_time,
				Tween.TRANS_QUAD)
	tween.start()
	yield(tween,"tween_completed")
	tween.queue_free()
	level_name_flyaway_time = 0
	level_name.bbcode_text = ""
	GameSaver.save_globally()
	pass

func update_hint():
	if not Utils.is_main_game_started:
		hint_label.bbcode_text = ""
	#find all shoter
	var has_ready_shoter = false
	var all_failed_shoot = true
	var has_shoter = false
	for i in index_to_human_map:
		var human = index_to_human_map[i]
		if human and human.is_stoping and human.get("make_shot_time"):
			has_shoter = true
			if human.is_ready_shoot:
				has_ready_shoter = true
			if not human.failed_shoot:
				all_failed_shoot = false
			else:
				all_failed_shoot = all_failed_shoot
	all_failed_shoot = all_failed_shoot and has_shoter
	#if human get blocked, show block hint
	if current_human and current_human.is_blocked:
		hint_label.bbcode_text = "[center][color=yellow]right click[/color] on human to kick off him"
	#if used shot when none is ready, show wait ready hint
	elif all_failed_shoot:
		hint_label.bbcode_text = "[center][color=red]wait[/color] until shot is ready(stop rotating)"
	#if shot is ready, show shot ready hint
	elif has_ready_shoter:
		hint_label.bbcode_text = "[center][color=yellow]Left Click[/color] to shoot shots"
	#if there is lightning, show magic hint
	#if none, show space hint
	else:
		if LevelManager.current_level ==1 and Utils.is_main_game_started:
			hint_label.bbcode_text = "[center]press [color=red]space[/color] to stop moving"
		else:
			hint_label.bbcode_text = ""

func _process(delta):
	update_hint()
	if level_name.bbcode_text.length()>0 and level_name_flyaway_time>0:
		var text  = LevelManager.get_level_info().name
		level_name.bbcode_text = "\n\n\n\n" + "[center][tornado radius="+String(level_name_flyaway_time)+" freq=2]"+text
	if not Utils.is_main_game_started:
		return
	if can_generate_player:
		#var t_rand = Utils.randomi(10)
		var human_instance = generator_instance.pop_waiting_human()
		if not human_instance:
			return
		human_instance.init(move_dir)
		current_human = human_instance
#		print(Utils.game_bottom_left)
#		if move_dir == Vector2.RIGHT:
#			human_instance.position = Utils.index_to_position(Utils.game_bottom_left) 
#		else:
#			human_instance.position = Utils.index_to_position(Utils.game_bottom_right) 
		#human.add_child(human_instance)
		can_generate_player = false
		#move_dir = -move_dir

func init_platformer():
	for i in range(3):
		var platformer_instance = platformer_scene.instance()
		$platformer.add_child(platformer_instance)
		platformer_instance.position = Utils.index_to_position(Utils.game_screen_bottom_left+Vector2(i*4,0) - Vector2(0.5,0))

func init_generator_and_platformer():
	Moon.update_normal_face()
	init_platformer()	
	
	generator_instance = generator_scene.instance()
	Generator = generator_instance
	add_child(generator_instance)
			
func _on_Timer_timeout():
	can_input = true
	
func end():
	dialog_instance.will_free()
	#finish dialog
	if dialog_state == -1:
		#prolog
		LevelManager.current_level = 1
		
		Utils.update_game_level()
		init_generator_and_platformer()
		show_level_start_dialog()
		
	elif dialog_state == 0:
		#game start
		Utils.main_game_start()
		MusicManager.play_music("level_game")
		can_generate_player = true
		pass
	elif dialog_state == 1:
		Utils.main_game_stop()
		LevelManager.next_level()
		Utils.update_game_level()
		Moon.update_normal_face()
		yield(LevelManager.level_up_scene_change(),"completed")
		Utils.clear_all_children(human)
		Utils.generator.clean_current_human()
		index_to_human_map.clear()
		index_to_passthrough_map.clear()
		
		init_platformer()
		
		show_level_start_dialog()
		
#	if LevelManager.current_level == -1:
#		#prolog
#		pass
#	else:
#		pass
	
	
	
func trigger(trigger_name):
	match trigger_name:
		"moon_shock":
			Moon.play_face_anim()
		"throw_meteor":
			yield(Moon.throw_meteors(),"completed")
		"show_moon_face":
			Moon.show_face(true)
		"hide_moon_face":
			Moon.show_face(false)	
			$AudioStreamPlayer2D.play()
		"change_normal_face":
			Moon.change_normal_face_to_normal()
		"end":
			end()
		"end_game":
			LevelManager.finished_game = true
			GameSaver.save_globally()
			Events.emit_signal("game_end")
		"show_advertisement_withmoon":
			var advertisement_instance = advertisement.instance()
			advertisement_instance.show_moon()
			$advertisement.add_child(advertisement_instance)
		"show_advertisement":
			Utils.clear_all_children(human)
			Utils.clear_all_children($platformer)
			advertisement_instance = advertisement.instance()
			$advertisement.add_child(advertisement_instance)
		"hide_advertisement":
			advertisement_instance.queue_free()
		
			
	yield(get_tree(), 'idle_frame')


func _on_Button_pressed():
	Events.emit_signal("game_end")
	pass # Replace with function body.


func _on_dialog_button_pressed():
	if dialog_instance:
		dialog_instance.skip_dialog()
