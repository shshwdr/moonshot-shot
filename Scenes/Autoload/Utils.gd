extends Node

var tile_length = 80

var half_tile_size = Vector2(tile_length/2,tile_length/2)
var rng:RandomNumberGenerator = RandomNumberGenerator.new()
var maingame:MainGame
var moon

var width_index = 10
var height_index = 10
var screen_height_index = 11

var is_main_game_started = true

var wait_time = 0.2

var DIR_UP = Vector2(0,1)

func _ready():
	rng.randomize()

func on_border(index:Vector2):
	if index.x == 0 or index.x == width_index-1:
		return true
	return false
	
func in_bound(index:Vector2, width,height):
	return index.x>=0 and index.x<width and index.y>=0 and index.y<height	
	
func in_screen(index:Vector2):
	return in_bound(index, width_index,height_index)
	
func in_large_screen(index:Vector2):
	return in_bound(index, width_index,screen_height_index)
	
	
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
	
func move_position_by(character,index_position):
	var current_position  = character.position
	var target_position =  position_move_by(character.position,index_position)
	var tween = Tween.new()

	add_child(tween)
	tween.interpolate_property(
				character, 
				"position", 
				current_position,target_position, wait_time,
				Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(tween,"tween_completed")
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
