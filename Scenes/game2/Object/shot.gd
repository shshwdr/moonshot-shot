extends Area2D
onready var tween = $Tween

var move_dir = Vector2.UP
var is_shot = false
var lived_time = 0
var is_moving = false
func index_position():
	return Utils.position_to_index(position)

func move():
	yield(Utils.move_position_by(self,tween,move_dir),"completed")

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
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Shot_area_entered(area):
	if not is_shot and area == Utils.moon:
		is_shot = true
		Utils.moon.get_shot()
		$Sprite.visible = false
		#queue_free()
