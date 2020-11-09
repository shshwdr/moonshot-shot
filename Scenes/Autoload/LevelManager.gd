extends Node



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	pass
	
func level_up():
	
	

	#level end dialog
	print("level end dialog")
	yield(get_tree().create_timer(2), "timeout")
	yield(level_up_scene_change(),"completed")
	
	#start next level
	
func start_level():
	#load level data
	#create base
	pass

func level_up_scene_change():
	var move_up_dir = Vector2(0,-15)
	var move_up_time = 1
	#move camera up and moon up
	Utils.move_position_by( Utils.camera,move_up_dir,move_up_time,Tween.TRANS_QUINT, Tween.EASE_OUT)
	Utils.move_position_by(Utils.moon,move_up_dir,move_up_time,Tween.TRANS_BACK, Tween.EASE_OUT)
	Utils.move_position_by(Utils.generator,move_up_dir,move_up_time*3,Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	
	yield(get_tree().create_timer(3), "timeout")
	#move spaceship later
	pass
	
func get_level():
	return 0
	
	

