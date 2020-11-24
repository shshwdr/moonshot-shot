extends Human


var strong_max_health = 5

func _ready():
	max_health = strong_max_health
	health = strong_max_health

func stop():
	.stop()
	#("stop ",current_index_position)
	Utils.maingame.add_passthrough(current_index_position+Vector2.UP)

func die():
	Utils.maingame.remove_passthrough(current_index_position+Vector2.UP)
	.die()
	
