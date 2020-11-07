extends Node2D

class_name MainGame

var moon_scene = preload("res://Scenes/Object/Moon.tscn")
var generator_scene = preload("res://Scenes/Object/Generator.tscn")
var shot_scene = preload("res://Scenes/Object/shot.tscn")
onready var human = $human
onready var bullets = $bullets
onready var timer = $Timer
var can_input = true


var index_to_human_map ={}
#var human_to_index_map ={}

func has_column_occupied(index_position):
	for i in range(Utils.height_index):
		if has_occupied(Vector2(index_position.x,i)):
			return true
	return false
	
func column_occupied_count(index_position):
	var res = 0
	for i in range(Utils.height_index):
		if has_occupied(Vector2(index_position.x,i)):
			res+=1
	return res
	
func get_highest_in_column(index_position):
	for i in range(0,Utils.height_index):
		if has_occupied(Vector2(index_position.x,i)):
			return Vector2(index_position.x,i)
	return null

func change_occupy(old_index_position,new_index_position):
	if not index_to_human_map.has(old_index_position) :
		printerr("in change occupy, human does not exist in %s"%String(old_index_position))
		return
	if index_to_human_map.has(new_index_position) :
		printerr("human do exist in %s"%String(new_index_position))
		return
	var human = index_to_human_map.get(old_index_position)
	index_to_human_map.erase(old_index_position)
	index_to_human_map[new_index_position] = human
	print("changed occupy ",index_to_human_map, old_index_position, new_index_position)
	

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

func has_occupied(index_position):
	#print(index_to_human_map,index_position)
	return index_to_human_map.has(index_position) 

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
	#print(index)
	if has_column_occupied(index):
		var index_position = get_highest_in_column(index)
		var human_instance = shot_scene.instance()
		human_instance.position = Utils.index_to_position(index_position)
		human.add_child(human_instance)


func _input(event):
	if not can_input:
		return
	if event is InputEventMouseButton and event.pressed:
#		if event.button_index == 1:
#			can_input = false
#			timer.start()
#			var touch = event.position
#			var index = Utils.position_to_index(touch)
#			on_touched_tile(index)
#		el
		if event.button_index == 2:
			can_input = false
			timer.start()
			var touch = event.position
			var index = Utils.position_to_index(touch)
			on_touched_shot(index)
		


# Called when the node enters the scene tree for the first time.
func _ready():
	timer.wait_time = Utils.wait_time*4
	Utils.maingame = self
	var moon_instance = moon_scene.instance()
	add_child(moon_instance)
	var generator_instance = generator_scene.instance()
	add_child(generator_instance)
	




func _on_Timer_timeout():
	can_input = true
