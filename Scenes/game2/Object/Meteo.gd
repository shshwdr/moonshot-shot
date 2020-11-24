extends Area2D


var move_dir = Vector2.DOWN
var is_shot = false
var damaged_human = {}
onready var tween = $Tween
var is_moving = false
var lived_time = 0

func index_position():
	return Utils.position_to_index(position)
	
func init(dir):
	move_dir = dir
	match dir:
		Vector2.DOWN:
			pass
		Vector2.UP:
			rotation_degrees = 180
		Vector2.RIGHT:
			rotation_degrees = -90
		Vector2.LEFT:
			rotation_degrees = 90

func move():
#	timer.start()
#	yield(timer, "timeout")
	yield(Utils.move_position_by(self,tween,move_dir),"completed")
#	if Utils.maingame.has_occupied(index_position()):
#		var human = Utils.maingame.index_to_human_map[index_position()]
#		human.damage(1)
#		#Utils.maingame.remove_occupy(index_position())
#		queue_free()
#	pass

	
func _ready():
	pass
#	while true:
#		yield(move(),"completed")
#		#check collision
#		#check out of screen
	


func _on_Moon_area_entered(area):
	#print(area, " ", area.is_in_group("human"))
	if  area.is_in_group("human"):
		is_shot = true
		area = Utils.maingame.get_above_human_if_existed(area)
		area.damage(1)
		
		$Sprite.visible = false
		
		#queue_free()
func _process(delta):
	if is_moving:
		return
	if is_shot:
		call_deferred('free')
		#queue_free()
		return
	if not Utils.in_screen(index_position()):
		call_deferred('free')
		return
	if not is_moving:
		is_moving = true
		yield(move(),"completed")
		is_moving = false
		#queue_free()
