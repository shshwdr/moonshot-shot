
extends Area2D

class_name Human

onready var sprite = $Sprite
onready var timer = $Timer

var start_go = false

var move_dir = Vector2.RIGHT

var is_moving = true
var is_stoping = false
var stopped = false
var max_health = 3
var health = max_health
	
func damage(d):
	health -=d
	var ratio = (max_health - health) / float(max_health - 1)
	#sprite.self_modulate = Color(ratio,0,0,1)
	sprite.material.set_shader_param("changeColorRatio",ratio)
	if health == 0:
		Utils.maingame.remove_occupy(index_position())
		if not is_stoping:
			#if havent stopped, stop it.
			stop()

func move_up():
#	timer.start()
#	yield(timer, "timeout")
	yield(Utils.move_position_by(self,Vector2.UP),"completed")
	pass

func ready_to_start():
	return index_position().y == Utils.game_screen_bottom_left.y-1

func index_position():
	return Utils.position_to_index(position)

func init(_move_dir):
	move_dir = _move_dir
	start_go = true

func _ready():
	timer.wait_time = Utils.wait_time
#	while Utils.maingame.has_occupied(index_position()):
#		yield(move_up(),"completed")
	is_moving = false
#	sprite.frame = 1
#	sprite.self_modulate = Color(0.5,0.5,0.5,1)
#	Utils.maingame.occupy(index_position(),self)
	pass

func in_game_screen():
	
	var index = index_position()
	return Utils.in_game_screen(index)

func _process(delta):
	if not start_go:
		return
	if not Utils.is_main_game_started:
		return 
	if not is_moving and not is_stoping:
		
		var index = index_position()
		
		var possible_dirs = []
		#if outside of game screen, move forward
		if not Utils.in_screen(index):
			stop()
			queue_free()
			return
		if not Utils.in_game_screen(index+move_dir):
			possible_dirs.push_back(move_dir)
		else:
			
			var dir_next = move_dir
			var dir_below = dir_next+Vector2.DOWN
			#if can go down, go down
			while Utils.can_occupy(index+dir_below):
				dir_next = dir_below
				dir_below = dir_below+Vector2.DOWN
				
			possible_dirs.push_back(dir_next)
			var one_level_higher = dir_next+Vector2.UP
			possible_dirs.push_back(one_level_higher)
		
		
		var moved = false
		#print("next position ",possible_positions)
		for dir in possible_dirs:
			var next_position = index+dir
			if not Utils.maingame.has_occupied(next_position):#Utils.can_occupy(next_position):
				is_moving = true
				Utils.maingame.change_occupy(index,next_position,self)
				
				yield(Utils.move_position_by(self,dir),"completed")
				is_moving = false
				moved = true
				break
		if moved == false:
			if in_game_screen():
				#no way to move, stop
				stop()
			
func stop():
	print("stop")
	is_stoping = true
	
	Events.emit_signal("player_stopped")
		
func get_input():
	if Utils.is_main_game_started:
		if not in_game_screen():
			return
		if not is_stoping:
			if Input.is_action_pressed(Utils.interact_key):
				print("interact key pressed")
				stop()
func _physics_process(delta):
	get_input()
