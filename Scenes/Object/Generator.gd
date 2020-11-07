extends Area2D

onready var timer = $Timer
onready var sprite = $Sprite
onready var tween = $Tween
onready var generateTimer = $GenerateTimer
var human_scene = preload("res://Scenes/Object/Human.tscn")
var can_input = true
var inputs = {
			"ui_right": Vector2.RIGHT,
			"ui_left": Vector2.LEFT,
			#"ui_up": Vector2.UP,
			#"ui_down": Vector2.DOWN
			}
var interact_input = "interact"

func index_position():
	return Utils.position_to_index(position)

func move(move_dir):
	if Utils.in_large_screen(index_position()+move_dir):
		yield(Utils.move_position_by(self,move_dir),"completed")
#	timer.start()
#	yield(timer, "timeout")
	pass



# Called when the node enters the scene tree for the first time.
func _ready():
	timer.wait_time = Utils.wait_time
	var index_position = Vector2(Utils.width_index/2,Utils.height_index)
	position = Utils.index_to_position(index_position)

func interact(dir):
	
	yield(move(dir),"completed")

func get_input():
	if Utils.is_main_game_started:
		if can_input:
			
			for dir in inputs.keys():
				if Input.is_action_pressed(dir):
					move(inputs[dir])

func _physics_process(delta):
	get_input()

func _on_Timer_timeout():
	can_input = true


func _on_GenerateTimer_timeout():
	var human_instance = human_scene.instance()
	human_instance.position = Utils.index_to_position(index_position()+Vector2(0,-1))
	Utils.maingame.human.add_child(human_instance)
	pass # Replace with function body.
