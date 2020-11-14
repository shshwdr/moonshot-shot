extends Human


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func stop():
	.stop()
	print("stop ",current_index_position)
	Utils.maingame.add_passthrough(current_index_position+Vector2.UP)

func die():
	Utils.maingame.remove_passthrough(current_index_position+Vector2.UP)
	.die()
	
