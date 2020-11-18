extends Area2D

onready var timer = $Timer
onready var tween = $Tween
onready var faceResetTimer = $FaceResetTimer
onready var faceAnimationPlayer  = $faceAnimationPlayer


var drunk_behavior_info

var meteo_scene = preload("res://Scenes/game2/Object/Meteo.tscn")
var thunder_scene = preload("res://Scenes/game2/Object/Thunder.tscn")
var target_index_position
var move_dir = Vector2.RIGHT
var current_drunk_hit_count = 0
var drunk_upgrade_hit_count = [1,1,1]
var sober_time = [0,50,10,10]
var current_sober_time = 0
var drunk_level = 0
var is_shotable = true

var drunk_behavior_speed = 1

#var level_to_face = [
#]

var face_to_normal_anim = {
	"res://art/moon/moon_face_serious.png":"normal_blink",
	"res://art/moon/moon_face_sleep.png":"normal_sleep",
}

onready var face_sprite = $face



var move_time = 0.4


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
	yield(Utils.move_position_by(self,move_dir+drunk_move_dir,move_time / float(drunk_behavior_speed)),"completed")
	drunk_move_dir = -drunk_move_dir
	pass


func shoot():
	faceAnimationPlayer.play("hit")
	faceResetTimer.wait_time = 0.2
	faceResetTimer.start()
	var meteo_instance = meteo_scene.instance()
	meteo_instance.position = Utils.index_to_position( target_index_position)
	if LevelManager.get_level_info().get("is_powerful",false):
		meteo_instance.scale = Vector2(4,4)
	Utils.maingame.bullets.add_child(meteo_instance)
	timer.start()
	yield(timer, "timeout")
	pass
	
func generate_thunder():
	var thunder_instance = thunder_scene.instance()
	var thunder_position = Utils.randomi_vector2(Utils.game_screen_top_left,Utils.game_screen_top_right)
	thunder_instance.position = Utils.index_to_position(thunder_position )
	Utils.maingame.bullets.add_child(thunder_instance)
	
func throw_meteors():
	var human_count = LevelManager.get_level_info().target_height - 1
	human_count = 1
	for i in range(human_count*3):
		
		var meteo_instance = meteo_scene.instance()
		meteo_instance.scale = Vector2(4,4)
		meteo_instance.position = Utils.index_to_position(index_position())
		Utils.maingame.bullets.add_child(meteo_instance)
		timer.start()
		yield(timer, "timeout")
	yield(get_tree(), 'idle_frame')
	
func update_drunk_behavior():
	var level_drunk_behavior_info =  drunk_behavior_info[0]
	var current_drunk_behavior_info = level_drunk_behavior_info.get_drunk[drunk_level]
	print(drunk_level, " ",current_drunk_behavior_info)
	if current_drunk_behavior_info.size()==0:
		#reset states
		drunk_behavior_speed = 1
		return
	#random pick
	var picked_drunk_behavior = current_drunk_behavior_info[0].behavior
	
	for key in picked_drunk_behavior:
		match key:
			"speed":
				drunk_behavior_speed = picked_drunk_behavior[key]
	
	pass

func get_shot():
	if not is_shotable:
		return
	is_shotable = false
	Utils.camera.start_shake(1,0.02,3)
	faceAnimationPlayer.play("beHit")
	faceResetTimer.wait_time = 0.2
	faceResetTimer.start()
	
	current_drunk_hit_count+=1
	if drunk_level >= drunk_upgrade_hit_count.size():
		current_drunk_hit_count = 0
		current_sober_time = 0
	elif current_drunk_hit_count>=drunk_upgrade_hit_count[drunk_level]:
		current_drunk_hit_count = 0
		drunk_level+=1
		update_drunk_behavior()
		current_sober_time = 0
		update_blush()
	yield(get_tree().create_timer(0.4), "timeout")
	is_shotable = true
	
func play_face_anim():
	face_sprite.frame = 4
	faceAnimationPlayer.stop()
	#faceAnimationPlayer.play("beHit")

func moon_behavior():
	match LevelManager.get_level_info().moon_behavior:
		"sleep":
			yield(get_tree(), 'idle_frame')
		"normal":
			yield(move(),"completed")
			
			if Utils.on_border(index_position()):
				move_dir = -move_dir
			
			target_index_position = index_position()#+Vector2(1,0)
			var column_occupied = Utils.maingame.column_occupied_count(target_index_position)
			for i in range(column_occupied):
				if not DebugSetting.moon_dont_attack:
					yield(shoot(),"completed")
				break
	

# Called when the node enters the scene tree for the first time.
func _ready():
	Utils.moon = self
	
	var level_folder = "res://resources/level"
	var file_path = '%s/%s.json' % [level_folder, "drunk_behavior"]
	drunk_behavior_info = Utils.load_json(file_path)
	
	timer.wait_time = Utils.wait_time
	var index_position = Utils.game_screen_top_center
	position = Utils.index_to_position(index_position)
	update_normal_face()
	update_blush()
	while true:
		if Utils.is_main_game_started:
			yield(moon_behavior(),"completed")
		#print(position,index_position())
			
		yield(get_tree(), 'idle_frame')
		#detect if more targets spawned
	
	pass # Replace with function body.




func _on_FaceResetTimer_timeout():
	update_normal_face()

func _input(event):
	if DebugSetting.can_jump_level and  event is InputEventKey and event.pressed:
		if event.scancode == KEY_0:
			finish_level()



func _process(delta):
	if drunk_level>0:
		current_sober_time+=delta
		moon_sober_up_visually(current_sober_time/float(sober_time[drunk_level]))
		if current_sober_time>sober_time[drunk_level]:
			current_sober_time = 0
			moon_sober_up_visually(1)
			drunk_level-=1
			if drunk_level == 2:
				drunk_level-=1
			
			update_drunk_behavior()
			
			update_blush()

func moon_sober_up_visually(ratio):
	$bg.material.set_shader_param("changeColorRatio",ratio)

func finish_level():
	Utils.is_main_game_started = false
	#moon stop and move up
	yield(Utils.move_position_by(self,Vector2.UP*Utils.moon_jump_height,0.4,Tween.TRANS_BACK, Tween.EASE_OUT),"completed")
	LevelManager.level_up()

func _on_Moon_area_entered(area):
	if Utils.is_main_game_started:
		if area.is_in_group("human"):
			#stop current game
			finish_level()
			pass


func _on_ThunderTimer_timeout():
	if LevelManager.get_level_info().get("has_thunder",false):
		generate_thunder()
