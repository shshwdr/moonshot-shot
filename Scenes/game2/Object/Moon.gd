extends Area2D

onready var timer = $Timer
onready var tween = $Tween
onready var faceResetTimer = $FaceResetTimer
onready var faceAnimationPlayer  = $faceAnimationPlayer
var meteo_scene = preload("res://Scenes/game2/Object/Meteo.tscn")
var target_index_position
var move_dir = Vector2.RIGHT
var current_drunk_hit_count = 0
var drunk_upgrade_hit_count = 1



var level_to_face = [
	preload("res://art/moon/moon_serious.png"),
]

var face_to_normal_anim = {
	preload("res://art/moon/moon_serious.png"):"normal_blink",
}

onready var face_sprite = $face

var move_time = 0.4

var drunk_level = 0

var blush_textures = [
	null,
	preload("res://art/moon/moon_blush.png"),
	preload("res://art/moon/moon_bigBlush.png"),
	preload("res://art/moon/moon_hugeBlush.png"),
]

func update_blush():
	$blush.texture = blush_textures[min(drunk_level,blush_textures.size()-1)]

func update_normal_face():
	face_sprite.texture = level_to_face[Utils.get_level()]
	faceAnimationPlayer.play(face_to_normal_anim[face_sprite.texture])

func index_position():
	return Utils.position_to_index(position)

func move():
	yield(Utils.move_position_by(self,move_dir,move_time),"completed")
	pass

func shoot():
	faceAnimationPlayer.play("hit")
	faceResetTimer.wait_time = 0.2
	faceResetTimer.start()
	var meteo_instance = meteo_scene.instance()
	meteo_instance.position = Utils.index_to_position( target_index_position)
	Utils.maingame.bullets.add_child(meteo_instance)
	timer.start()
	yield(timer, "timeout")
	pass

func get_shot():
	
	faceAnimationPlayer.play("beHit")
	faceResetTimer.wait_time = 0.2
	faceResetTimer.start()
	
	current_drunk_hit_count+=1
	if current_drunk_hit_count>=drunk_upgrade_hit_count:
		current_drunk_hit_count = 0
		drunk_level+=1
		update_blush()
	move_time*=2

# Called when the node enters the scene tree for the first time.
func _ready():
	Utils.moon = self
	timer.wait_time = Utils.wait_time
	var index_position = Utils.screen_start_vector
	position = Utils.index_to_position(index_position)
	update_normal_face()
	update_blush()
	while true:
		#print(position,index_position())
		yield(move(),"completed")
		
		if Utils.on_border(index_position()):
			move_dir = -move_dir
		
		target_index_position = index_position()#+Vector2(1,0)
		var column_occupied = Utils.maingame.column_occupied_count(target_index_position)
		for i in range(column_occupied):
			yield(shoot(),"completed")
			break
		#detect if more targets spawned
	
	pass # Replace with function body.




func _on_FaceResetTimer_timeout():
	update_normal_face()
