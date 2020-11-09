extends Node

var tile_length = 32

var half_tile_size = Vector2(tile_length/2,tile_length/2)
var rng:RandomNumberGenerator = RandomNumberGenerator.new()
var maingame
var moon
var generator
var width_offset = 4
var width_end_offset = 1
var height_offset = 3

var camera


var screen_start_vector = Vector2(width_offset,height_offset)
var width_index = 10
var height_index = 2

var game_screen_bottom_left = Vector2(width_offset,height_offset+height_index)
var game_screen_bottom_right = Vector2(width_offset+width_index,height_offset+height_index)

var width_total = width_offset+width_index+width_end_offset
var height_total = height_offset+height_index+height_offset
var interact_key = "interact"
var interact_key_2 = "interact2"
var game_bottom_left = Vector2(0,height_offset+height_index-1)
var game_bottom_right = Vector2(width_total-1,height_offset+height_index-1)

var screen_height_index = 11

var is_main_game_started = true

var wait_time =0.4

var DIR_UP = Vector2(0,1)

func _ready():
	rng.randomize()

func on_border(index:Vector2):
	if index.x == width_offset or index.x == width_offset+width_index-1:
		return true
	return false
	
func in_bound(index:Vector2, width,height):
	return index.x>=0 and index.x<width and index.y>=0 and index.y<height	
	
func in_screen(index:Vector2):
	return in_bound(index, width_total,height_total)

func in_game_screen(index:Vector2):
	return in_bound_with_start_position(index, screen_start_vector, width_index,height_index)
	
func can_occupy(index:Vector2):
	#print(Utils.in_game_screen(index)," ",not Utils.maingame.has_occupied(index))
	return Utils.in_game_screen(index) and not Utils.maingame.has_occupied(index)
	
	
func in_large_screen(index:Vector2):
	return in_bound_with_start_position(index,screen_start_vector, width_index,screen_height_index)
	
	
func in_bound_with_start_position(index:Vector2, start_position,width,height):
	return index.x>=start_position.x and index.x<start_position.x+width and \
	index.y>=start_position.y and index.y<height+start_position.y	
	

func index_to_position(index:Vector2):
	var res = index*tile_length +half_tile_size
	return res
	
func position_to_index(position:Vector2):
	var res = (position - half_tile_size)/tile_length
	res = Vector2(round(res.x),round(res.y))
	return res
	
func move_position_by(character,index_position,move_time = wait_time, tween_trans = Tween.TRANS_LINEAR, tween_ease = Tween.EASE_IN):
	var current_position  = character.position
	var target_position =  position_move_by(character.position,index_position)
	var tween = Tween.new()

	add_child(tween)
	tween.interpolate_property(
				character, 
				"position", 
				current_position,target_position, move_time,
				tween_trans, tween_ease)
	tween.start()
	yield(tween,"tween_completed")
	#print("tween end")
	tween.queue_free()
	#character.position = position_move_by(character.position,index_position)

func position_move_to(character,index_position):
	character.position = index_to_position(index_position)
	
func position_move_by(position,index_position):
	var to_move_index_position = position_to_index(position)
	return index_to_position(to_move_index_position+index_position)
	
func randomi_2d(width,height):
	var w = rng.randi() % width
	var h = rng.randi() % height
	return Vector2(w,h)
func randomi(i):
	return rng.randi()%i

func sum_array(array):
	var sum = 0.0
	for element in array:
		 sum += element
	return sum

func random_distribution_array(array):
	var total_count = sum_array(array)
	var random_value = rng.randi_range(0,total_count)
	var increading_count = 0
	for i in array.size():
		increading_count+=array[i]
		if random_value<=increading_count:
			return i
	printerr("random array didn't return correctly")
	return 0
