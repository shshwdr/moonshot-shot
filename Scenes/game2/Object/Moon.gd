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



#var level_to_face = [
#]

var face_to_normal_anim = {
	"res://art/moon/moon_face_serious.png":"normal_blink",
	"res://art/moon/moon_face_sleep.png":"normal_sleep",
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
	var moon_face_texture = LevelManager.get_level_info().moon_type
	face_sprite.texture = load(moon_face_texture)
	faceAnimationPlayer.play(face_to_normal_anim[moon_face_texture])

func index_position():
	return Utils.position_to_index(position)

var drunk_move_dir = Vector2.ZERO

func move():
	yield(Utils.move_position_by(self,move_dir+drunk_move_dir,move_time),"completed")
	drunk_move_dir = -drunk_move_dir
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
	
func throw_meteors():
	var human_count = LevelManager.get_level_info().target_height - 1
	for i in range(human_count*3):
		
		var meteo_instance = meteo_scene.instance()
		meteo_instance.scale = Vector2(1.5,1.5)
		meteo_instance.position = Utils.index_to_position(index_position())
		Utils.maingame.bullets.add_child(meteo_instance)
		timer.start()
		yield(timer, "timeout")

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
	
func play_face_anim():
	face_sprite.frame = 4
	#faceAnimationPlayer.play("beHit")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	Utils.moon = self
	timer.wait_time = Utils.wait_time
	var index_position = Utils.game_screen_top_center
	position = Utils.index_to_position(index_position)
	update_normal_face()
	update_blush()
	while Utils.is_main_game_started:
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


func _on_Moon_area_entered(area):
	if Utils.is_main_game_started:
		if area.is_in_group("human"):
			#stop current game
			Utils.is_main_game_started = false
			#moon stop and move up
			yield(Utils.move_position_by(self,Vector2.UP*2,0.4,Tween.TRANS_BACK, Tween.EASE_OUT),"completed")
			LevelManager.level_up()
			pass
