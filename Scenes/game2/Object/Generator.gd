extends Area2D

onready var timer = $Timer
onready var sprite = $Sprite
onready var tween = $Tween
onready var generateTimer = $GenerateTimer

var human_type = [
	preload("res://Scenes/game2/Object/Human.tscn"),
	preload("res://Scenes/game2/Object/Human_shoter.tscn")
]

var waiting_human_instance = []

var human_ratio = [7,3]

var lined_up_count = 4

var inputs = {
			"ui_right": Vector2.RIGHT,
			"ui_left": Vector2.LEFT,
			#"ui_up": Vector2.UP,
			#"ui_down": Vector2.DOWN
			}
var interact_input = "interact"

func index_position():
	return Utils.position_to_index(position)

#func move(move_dir):
#	if Utils.in_large_screen(index_position()+move_dir):
#		yield(Utils.move_position_by(self,move_dir),"completed")
##	timer.start()
##	yield(timer, "timeout")
#	pass

func _process(delta):
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	Utils.generator = self
	#position based on linedup count
	var index_position = Utils.game_screen_bottom_left - Vector2(2,lined_up_count+1) 
	position = Utils.index_to_position(index_position)
#	for i in range(lined_up_count):
#		var human_type_id = Utils.random_distribution_array(human_ratio)
#		var human_instance = human_type[human_type_id].instance()
#		human_instance.position = position
#		Utils.maingame.human.add_child(human_instance)
#		yield(Utils.move_position_by(human_instance,Vector2(0,1)),"completed")
	
	
#	timer.wait_time = Utils.wait_time
#	var index_position = Vector2(Utils.width_index/2,Utils.height_index+Utils.screen_start_vector.y)
#	position = Utils.index_to_position(index_position)

#func interact(dir):
#
#	yield(move(dir),"completed")
#
#func get_input():
#	pass
#	if Utils.is_main_game_started:
#		if can_input:
#
#			for dir in inputs.keys():
#				if Input.is_action_pressed(dir):
#					move(inputs[dir])
#
#func _physics_process(delta):
#	get_input()
#
#func _on_Timer_timeout():
#	can_input = true
#
#

func pop_waiting_human():
	var human = waiting_human_instance.front()
	if human and human.ready_to_start():
		waiting_human_instance.pop_front()
	
		return human

func move_all_down():
	for human in waiting_human_instance:
		Utils.move_position_by(human,Vector2.DOWN)

func _on_GenerateTimer_timeout():
	if waiting_human_instance.size()< lined_up_count:
		var human_type_id = Utils.random_distribution_array(LevelManager.get_level_info().human_type)
		var human_instance = human_type[human_type_id].instance()
		human_instance.position = position
		Utils.maingame.human.add_child(human_instance)
		waiting_human_instance.push_back(human_instance)
		move_all_down()
