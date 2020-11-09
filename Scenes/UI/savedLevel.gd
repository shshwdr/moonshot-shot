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
	$Label.text = "Day %d   health:%d coins:%d reputation:%d\n   saved at %d/%d/%d %d:%d:%d"%\
	[data.day,data.health,data.earning,data.reputation,data.saved_time.month,data.saved_time.day,data.saved_time.year\
	,data.saved_time.hour,data.saved_time.minute,data.saved_time.second]
#	data["day"] = get_visual_level()
#	data["health"] = ResourceManager.current_health
#	data["saved_time"] = OS.get_datetime()
#	data["earning"] = ResourceManager.current_earning
#	data["reputation"] = ResourceManager.current_reputation
	#year, month, day, weekday, dst (Daylight Savings Time), hour, minute, second.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_savedLevel_pressed():
	pass
#	LevelManger.load_saved_data(data)
#	#yield(get_tree(), 'idle_frame')
#	Util.clear_all_children(Util.game_root)
#	var zoo_instance = zoo.instance()
#	Util.game_root.add_child(zoo_instance)
#	#yield(zoo_instance, "ready")
#	#yield(get_tree(), 'idle_frame')
#	zoo_instance.level_continue()
