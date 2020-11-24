extends Area2D

onready var timer = $Timer
onready var tween = $Tween
onready var faceResetTimer = $FaceResetTimer
onready var faceAnimationPlayer  = $faceAnimationPlayer
onready var thunderTimer = $ThunderTimer
onready var face_bg = $bg
onready var sprite = $bg
onready var moon_chat = $dialog/Node2D/moon_chat
onready var moon_chat_timer = $dialog/Node2D/moon_chat_timer
onready var dialog = $dialog

var moon_chat_wait_time = 7

var drunk_behavior_info

var meteo_scene = preload("res://Scenes/game2/Object/Meteo.tscn")
var thunder_scene = preload("res://Scenes/game2/Object/Thunder.tscn")
var target_index_position
var move_dir = Vector2.RIGHT
var current_drunk_hit_count = 0
var drunk_upgrade_hit_count = [1,1,1]
var sober_time = [0,30,10,10]
var current_sober_time = 0
var drunk_level = 0
var is_shotable = true
var picked_drunk_content

enum moon_state_enum{none,sleep, move_drunk, shoot_drunk}

var moon_state = moon_state_enum.none

var drunk_behavior_speed = 1
var drunk_behavior_ammo_speed = 1
var drunk_shoot_dirs = [Vector2.DOWN,Vector2.RIGHT,Vector2.UP,Vector2.LEFT]
var drunk_shoot_current = 0

#var level_to_face = [
#]

var face_to_normal_anim = {
	"res://art/moon/moon_face_serious.png":"normal_blink",
	"res://art/moon/moon_face_sleep.png":"normal_sleep",
	"res://art/moon/moon-innocent.png":"normal_rotation",
	"res://art/moon/moon-ohILoveItt.png":"normal_rotation",
	"res://art/moon/moon-swollow.png":"normal_rotation",
}

onready var face_sprite = $face



var move_time = 0.3


var blush_textures = [
	null,
	preload("res://art/moon/moon_blush.png"),
	preload("res://art/moon/moon_bigBlush.png"),
	preload("res://art/moon/moon_hugeBlush.png"),
]

func update_blush():
	$blush.texture = blush_textures[min(drunk_level,blush_textures.size()-1)]

func show_face(should_show):
	face_bg.visible = should_show

func change_normal_face_to_normal():
	var moon_face_texture = "res://art/moon/moon_face_serious.png"
	face_sprite.texture = load(moon_face_texture)
	faceAnimationPlayer.play(face_to_normal_anim[moon_face_texture])

func update_normal_face():
	var moon_face_texture = LevelManager.get_level_info().moon_type
	if moon_state == moon_state_enum.sleep:
		moon_face_texture = "res://art/moon/moon_face_sleep.png"
	face_sprite.texture = load(moon_face_texture)
	faceAnimationPlayer.play(face_to_normal_anim[moon_face_texture])
	if LevelManager.get_level_info().get("hide",false):
		face_bg.visible = false
	else:
		face_bg.visible = true

func index_position():
	return Utils.position_to_index(position)

var drunk_move_dir =Vector2.DOWN

func move():
	var current_drunk_move_dir  = Vector2.ZERO
	var current_move_time = move_time / float(drunk_behavior_speed)
	if moon_state == moon_state_enum.move_drunk:
		current_drunk_move_dir = drunk_move_dir
		#current_move_time*=1.5
	yield(Utils.move_position_by(self,tween,move_dir+current_drunk_move_dir,current_move_time),"completed")
	drunk_move_dir = -drunk_move_dir
	pass


func shoot():
	faceAnimationPlayer.play("hit")
	faceResetTimer.wait_time = 0.2
	faceResetTimer.start()
	
	timer.wait_time = Utils.wait_time / float(drunk_behavior_ammo_speed)
	for i in range(drunk_behavior_ammo_speed):
		
		var meteo_instance = meteo_scene.instance()
		var current_meteo_dir = drunk_shoot_dirs[drunk_shoot_current%drunk_shoot_dirs.size()]
		if moon_state == moon_state_enum.shoot_drunk:
			meteo_instance.init(current_meteo_dir)
			drunk_shoot_current+=1
			meteo_instance.position = Utils.index_to_position( target_index_position+current_meteo_dir)
		else:
			meteo_instance.position = Utils.index_to_position( target_index_position+Vector2.DOWN)
		if LevelManager.get_level_info().get("is_powerful",false):
			meteo_instance.scale = Vector2(4,4)
		Utils.maingame.bullets.call_deferred("add_child",meteo_instance)
		#Utils.maingame.bullets.add_child(meteo_instance)
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
	
	
	
func update_moon_chat():
	if picked_drunk_content:
		dialog.visible = true
		moon_chat.bbcode_text = picked_drunk_content
		moon_chat_timer.wait_time = moon_chat_wait_time
		moon_chat_timer.start()
	
func update_drunk_behavior():
	picked_drunk_content = null
	var level_drunk_behavior_info =  drunk_behavior_info[min(drunk_behavior_info.size()-1,LevelManager.current_level)]
	var current_drunk_behavior_info = level_drunk_behavior_info.get_drunk[drunk_level]
	#(drunk_level, " ",current_drunk_behavior_info)
	if current_drunk_behavior_info.size()==0:
		#reset states
		drunk_behavior_speed = 1
		drunk_behavior_ammo_speed = 1
		moon_state = moon_state_enum.none
		return
	#random pick
	var random_behavior_id = Utils.rng.randi()%current_drunk_behavior_info.size()
	picked_drunk_content = current_drunk_behavior_info[random_behavior_id].content
	var picked_drunk_behavior = current_drunk_behavior_info[random_behavior_id].behavior
	
	for key in picked_drunk_behavior:
		match key:
			"speed":
				drunk_behavior_speed = picked_drunk_behavior[key]
			"get_sleep":
				if picked_drunk_behavior[key]:
					moon_state = moon_state_enum.sleep
				else:
					moon_state = moon_state_enum.none
			"ammo_speed":
				drunk_behavior_ammo_speed = picked_drunk_behavior[key]
			"move_drunk":
				if picked_drunk_behavior[key]:
					moon_state = moon_state_enum.move_drunk
				else:
					moon_state = moon_state_enum.none
			"shoot_randomly":
				if picked_drunk_behavior[key]:
					moon_state = moon_state_enum.shoot_drunk
				else:
					moon_state = moon_state_enum.none
				drunk_shoot_current = 0
	
	pass

func get_shot():
	if not is_shotable:
		return
	is_shotable = false
	Utils.camera.start_shake(0.3,0.02,2)
	faceAnimationPlayer.play("beHit")
	faceResetTimer.wait_time = 0.4
	faceResetTimer.start()
	
	
	current_drunk_hit_count+=1
	if drunk_level >= drunk_upgrade_hit_count.size():
		current_drunk_hit_count = 0
		current_sober_time = 0
	elif current_drunk_hit_count>=drunk_upgrade_hit_count[drunk_level]:
		current_drunk_hit_count = 0
		drunk_level+=1
		update_drunk_behavior()
		update_moon_chat()
		current_sober_time = 0
		update_blush()
	yield(get_tree().create_timer(0.6), "timeout")
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
			
			if moon_state == moon_state_enum.sleep:
				yield(get_tree(), 'idle_frame')
				return
			
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
			if thunderTimer.time_left==0:
				thunderTimer.start()
			yield(moon_behavior(),"completed")
		#print(position,index_position())
		else:
			if thunderTimer.time_left>0:
				thunderTimer.stop()
		yield(get_tree(), 'idle_frame')
		#detect if more targets spawned
	
	pass # Replace with function body.




func _on_FaceResetTimer_timeout():
	update_normal_face()

func _input(event):
	if DebugSetting.can_jump_level and  event is InputEventKey and event.pressed:
		if event.scancode == KEY_0:
			finish_level()
		if event.scancode == KEY_9:
			DebugSetting.moon_dont_attack = not DebugSetting.moon_dont_attack
		if event.scancode == KEY_8:
			print("memory usage ",OS.get_static_memory_usage())
			print("dynamic memory ",OS.get_dynamic_memory_usage())
		


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
			update_normal_face()

func moon_sober_up_visually(ratio):
	$bg.material.set_shader_param("changeColorRatio",ratio)

func finish_level():
	Utils.is_main_game_started = false
	#moon stop and move up
	moon_state = moon_state_enum.none
	update_normal_face()
	yield(Utils.move_position_by(self,tween, Vector2.UP*Utils.moon_jump_height,0.4,Tween.TRANS_BACK, Tween.EASE_OUT),"completed")
	LevelManager.level_up()
	
func reset_moon():
	drunk_behavior_ammo_speed = 1
	drunk_behavior_speed = 1
	moon_state = moon_state_enum.none
	drunk_level = min(drunk_level,1)
	current_drunk_hit_count = 0
	current_sober_time = 0

func _on_Moon_area_entered(area):
	if Utils.is_main_game_started:
		if area.is_in_group("human"):
			#stop current game
			finish_level()
			pass


func _on_ThunderTimer_timeout():
	if LevelManager.get_level_info().get("has_thunder",false):
		generate_thunder()


func _on_moon_chat_timer_timeout():
	dialog.visible = false
