extends Node2D

onready var human_scene = preload("res://Scenes/Object/Human.tscn")
onready var moon_scene = preload("res://Scenes/Object/Moon.tscn")
onready var human = $human


var index_to_human_map ={}
var human_to_index_map ={}

func has_occupied(index_position):
	print(index_to_human_map,index_position)
	return index_to_human_map.has(index_position)

func occupy(index, human_instance):
	index_to_human_map[index] = human_instance
	human_to_index_map[human_instance] = index

func on_touched_tile(index):
	print(index)
	var human_instance = human_scene.instance()
	human_instance.position = Utils.index_to_position(index)
	human.add_child(human_instance)
	#index_to_human_map[index] = human_instance
	#human_to_index_map[human_instance] = index
	#human_to_index_map[human_instance] = index
#	if not index_to_tile_map.has(index):
#		return
#	var tile = index_to_tile_map[index]
#	var player_path_to_tile = get_player_path_to(index)
#	if player_path_to_tile:
#		#print("path ",player_path_to_tile)
#		yield(player_instance.move_path(player_path_to_tile),"completed")
#		#move player
#		tile.cover_state = Constants.CoverState.None
#		tile.update()
#	else:
#		print("unaccessible")
#	#if not accessible, show warning
#	#if accessible, and has cover, move there and hide cover
#	#if is player, click player
#	#if not has cover, click tile
#	pass


func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		var touch = event.position
		var index = Utils.position_to_index(touch)
		on_touched_tile(index)

# Called when the node enters the scene tree for the first time.
func _ready():
	Utils.maingame = self
	var moon_instance = moon_scene.instance()
	add_child(moon_instance)


