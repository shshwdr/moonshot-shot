extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var move_dir = Vector2.RIGHT



func move():
	yield(Utils.move_position_by(self,move_dir,0.3),"completed")
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	Utils.camera = self
#	while Utils.is_main_game_started:
#		#print(position,index_position())
#		yield(move(),"completed")
#		move_dir = -move_dir
#		if Utils.on_border(index_position()):
#			move_dir = -move_dir
#
#		target_index_position = index_position()#+Vector2(1,0)
#		var column_occupied = Utils.maingame.column_occupied_count(target_index_position)
#		for i in range(column_occupied):
#			yield(shoot(),"completed")
#			break


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
