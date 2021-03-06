
extends Area2D

class_name Human

var past_time = 0
onready var sprite = $Sprite

var start_go = false
var is_blocked = false
var index = null

var move_dir = Vector2.RIGHT

var is_moving = true
var is_stoping = false
var stopped = false
var max_health = 3
var health = max_health
var current_index_position
var is_freed = false

onready var tween = $Tween
	
func damage(d):
	health -=d
	var ratio = (max_health - health) / float(max_health - 1)
	#sprite.self_modulate = Color(ratio,0,0,1)
	sprite.material.set_shader_param("changeColorRatio",ratio)
	if health <= 0:
		die()

func die():
	if not is_stoping:
		#if havent stopped, stop it.
		stop()
	Utils.maingame.remove_occupy(index_position())

func can_block_thunder():
	return false

func move_up():
	yield(Utils.move_position_by(self,tween,Vector2.UP),"completed")
	pass

func ready_to_start():
	return index_position().y == Utils.game_screen_bottom_left.y-1

func index_position():
	return Utils.position_to_index(position)

func init(_move_dir):
	move_dir = _move_dir
	start_go = true

func _ready():
#	while Utils.maingame.has_occupied(index_position()):
#		yield(move_up(),"completed")
	is_moving = false
	pass

func in_game_screen():
	if current_index_position:
		return Utils.in_game_screen(current_index_position)
	return false

func will_free():
	is_freed = true
	sprite.visible = false

func _process(delta):
	past_time+=delta
	if is_freed and not is_moving:
		queue_free()
		return
	is_blocked = false
	if not start_go:
		return
	if not Utils.is_main_game_started:
		return 
	if not is_moving and not is_stoping:
		#print("moving time ",past_time)
		var index = current_index_position#index_position()
		if not index:
			index = index_position()
		var possible_dirs = []
		#if out of screen, destroy
		if not Utils.in_screen(index):
			stop()
			queue_free()
			return
		#if outside of game screen, move forward
		if not Utils.in_game_screen(index+move_dir):
			possible_dirs.push_back(move_dir)
		else:
			#two options, move right, or move right above
			var dir_next = move_dir
			if Utils.can_occupy(index+dir_next):
				#right can be occupied, check down
				var dir_below = dir_next+Vector2.DOWN
				#if can go down, go down
				while Utils.can_occupy(index+dir_below):
					dir_next = dir_below
					dir_below = dir_below+Vector2.DOWN
					
				possible_dirs.push_back(dir_next)
			else:
				#right cannot be occupied, check right up
				var one_level_higher = dir_next+Vector2.UP
				possible_dirs.push_back(one_level_higher)
				
			
		
		#print("current position ",index," possible position ",possible_dirs)
		var moved = false
		#print("next position ",possible_positions)
		for dir in possible_dirs:
			var next_position = index+dir
			if not Utils.maingame.has_occupied(next_position):#Utils.can_occupy(next_position):
				#if next position can be pass through(like there is a ladder or rope, pass up
				var origin_dir = dir
				var origin_next_position = next_position
				while Utils.maingame.can_passthrough(next_position):
					dir+=Vector2.UP
					next_position = index+dir
				#print("next_position after ladder ",next_position)
				if Utils.maingame.has_occupied(next_position):
					continue
#					dir = origin_dir
#					next_position = origin_next_position
				is_moving = true
				Utils.maingame.change_occupy(index,next_position,self)
				current_index_position = next_position
				var test_position = next_position
				#print("before yield ",test_position," ",next_position," ",past_time)
				yield(Utils.move_position_by(self,tween,dir),"completed")
				#print("after yield ",test_position," ",next_position," ",past_time)
				is_moving = false
				moved = true
				break
		if moved == false:
			if in_game_screen():
				#no way to move, stop
				stop()
			else:
				is_blocked = true
				#is_blocked
			
func stop():
	#print("stop")
	is_stoping = true
	
	Events.emit_signal("player_stopped")
		
func get_input():
	if Utils.is_main_game_started:
		if not is_stoping:
			if Input.is_action_just_pressed(Utils.interact_key):
				
				if not in_game_screen():
					return
				#print("interact key pressed")
				#move stop to when finish moving
				stop()
				#in_game_screen()
func _physics_process(delta):
	get_input()
