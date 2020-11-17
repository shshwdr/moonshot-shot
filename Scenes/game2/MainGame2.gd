extends Node2D


var moon_scene = preload("res://Scenes/game2/Object/Moon.tscn")
var generator_scene = preload("res://Scenes/game2/Object/Generator.tscn")

var Moon
var Generator
onready var human = $human
onready var bullets = $bullets
onready var timer = $Timer
onready var line = $Line2D
var dialog_folder = "res://resources/dialog"

var dialog_instance 
var dialog_state = -1 #-1 prolog, 0 pre level, 1 end level

var generator_instance
var can_input = true
var can_generate_player = true

var move_dir = Vector2.RIGHT

var index_to_human_map ={}

var index_to_passthrough_map ={}

onready var level_name = $level_name
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
				remove_occupy(check_position)
	
	
	
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
		printerr("in change occupy, human does not exist in %s"%String(old_index_position))
		#return
	if index_to_human_map.has(new_index_position) :
		printerr("human do exist in %s"%String(new_index_position))
		return
	#var human = index_to_human_map.get(old_index_position)
	index_to_human_map.erase(old_index_position)
	index_to_human_map[new_index_position] = human
	#print("changed occupy ",index_to_human_map, old_index_position, new_index_position)
	

func remove_occupy(index_position):
	if not index_to_human_map.has(index_position) :
		printerr("in remove, human does not exist in %s"%String(index_position))
	var human = index_to_human_map.get(index_position)
	if human:
		human.queue_free()
	else:
		printerr("why no human here??",index_to_human_map, index_position ) 
	index_to_human_map.erase(index_position)
	
	#if there are human above, move them down
#	var index_above = index_position + Vector2.UP
#	while Utils.in_screen(index_above) and Utils.maingame.has_occupied(index_above):
#		var above_human = index_to_human_map[index_above]
#		Utils.maingame.change_occupy(index_above,index_position)
#		Utils.move_position_by(above_human,Vector2.DOWN)
#		index_position = index_above
#		index_above = index_above+Vector2.UP

func add_passthrough(index_position):
	print("add passthrough ",index_position)
	index_to_passthrough_map[index_position] = true
	
func remove_passthrough(index_position):
	index_to_passthrough_map.erase(index_position)

func can_passthrough(index_position):
	#print("can_passthrough ",index_position)
	print("can_passthrough ",index_to_passthrough_map,index_position)
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

func occupy(index, human_instance):
	index_to_human_map[index] = human_instance
	#human_to_index_map[human_instance] = index

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
	

	
func on_player_stopped():
	can_generate_player = true

func show_prolog():
	var file_path = '%s/%s.json' % [dialog_folder, "prolog"]
	var prolog = Utils.load_json(file_path)
	dialog_instance = DialogManager.select_dialog_multiple(self,prolog)
	yield(get_tree(), 'idle_frame')
	add_child(dialog_instance)
	dialog_state = -1
	dialog_instance.start_dialog()

func show_level_start_dialog():
	show_level_name()
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
	level_name.text = LevelManager.get_level_info().name
	yield(get_tree().create_timer(1), "timeout")
	level_name.text = ""
	GameSaver.save_globally()
	pass

func _process(delta):
	if not Utils.is_main_game_started:
		return
	if can_generate_player:
		#var t_rand = Utils.randomi(10)
		var human_instance = generator_instance.pop_waiting_human()
		if not human_instance:
			return
		human_instance.init(move_dir)
#		print(Utils.game_bottom_left)
#		if move_dir == Vector2.RIGHT:
#			human_instance.position = Utils.index_to_position(Utils.game_bottom_left) 
#		else:
#			human_instance.position = Utils.index_to_position(Utils.game_bottom_right) 
		#human.add_child(human_instance)
		can_generate_player = false
		#move_dir = -move_dir

func init_generator_and_platformer():
	Moon.update_normal_face()
	
	line.points[0] = Utils.index_to_position(Utils.game_screen_bottom_left) 
	line.points[1] =Utils.index_to_position( Utils.game_screen_bottom_right) 
	generator_instance = generator_scene.instance()
	Generator = generator_instance
	add_child(generator_instance)
			
func _on_Timer_timeout():
	can_input = true
	
func end():
	dialog_instance.queue_free()
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
		line.points[0] = Utils.index_to_position(Utils.game_screen_bottom_left) 
		line.points[1] =Utils.index_to_position( Utils.game_screen_bottom_right) 
		
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
		"end":
			end()
	yield(get_tree(), 'idle_frame')


func _on_Button_pressed():
	Events.emit_signal("game_end")
	pass # Replace with function body.
