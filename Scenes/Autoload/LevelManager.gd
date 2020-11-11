extends Node

var level_infos
var current_level = 0
var level_folder = "res://resources/level"


func is_prolog():
	return current_level == 0
# Called when the node enters the scene tree for the first time.
func _ready():
	load_levels_info()
	
func load_levels_info():
	var file_path = '%s/%s.json' % [level_folder, "level"]
	level_infos = Utils.load_json(file_path)


func _process(delta):
	pass
	
func level_up():

	#level end dialog
	print("level end dialog")
	#yield(get_tree().create_timer(2), "timeout")
	Utils.maingame.show_level_end_dialog()
	#start next level
	
func start_level():
	#load level data
	#create base
	pass

func level_up_scene_change():
	var move_up_dir = Vector2(0,-15)
	var move_up_time = 1
	
	var space_ship_diff = LevelManager.get_level_info().target_height-4
	#move camera up and moon up
	Utils.move_position_by( Utils.camera,move_up_dir,move_up_time,Tween.TRANS_QUINT, Tween.EASE_OUT)
	Utils.move_position_by(Utils.moon,move_up_dir,move_up_time,Tween.TRANS_BACK, Tween.EASE_OUT)
	Utils.move_position_by(Utils.generator,move_up_dir+ Vector2(0,1)*space_ship_diff,move_up_time*3,Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	Utils.update_offset(15)
	yield(get_tree().create_timer(3), "timeout")
	#move spaceship later
	pass
	
func get_level():
	return current_level


	
func get_level_info():
	if current_level>= level_infos.size():
		push_error("level %d more than define"%current_level)
	var res = level_infos[current_level].duplicate()
#	if DebugSetting.skip_main_game > 0:
#		res.level_length = DebugSetting.skip_main_game
	return res
	
func next_level():
	current_level+=1
	if current_level >=level_infos.size():
		Events.emit_signal("get_max_level")
	
	

