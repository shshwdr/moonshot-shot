extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var data
#var zoo = preload("res://scene/Zoo.tscn")

func init(_saved_data):
	data = _saved_data
# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = "Stage %d    %s"%\
	[data, LevelManager.get_one_level_info(data).name]
	
func _on_savedLevel_pressed():
	LevelManager.load_level(data)
	
	Events.emit_signal("game_start")
	pass
#	LevelManger.load_saved_data(data)
#	#yield(get_tree(), 'idle_frame')
#	Util.clear_all_children(Util.game_root)
#	var zoo_instance = zoo.instance()
#	Util.game_root.add_child(zoo_instance)
#	#yield(zoo_instance, "ready")
#	#yield(get_tree(), 'idle_frame')
#	zoo_instance.level_continue()
