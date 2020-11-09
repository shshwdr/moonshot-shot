extends Control



var game_scene = preload("res://Scenes/game2/MainGame2.tscn")
var starting_scene = preload("res://Scenes/UI/StartingPage.tscn")

onready var control = $Control

# Called when the node enters the scene tree for the first time.
func _ready():
	Utils.game_root = control
	Events.connect("game_start",self,"on_game_start")
	Events.connect("game_end",self,"on_game_end")

func reload_scene(scene):
	Utils.reload_scene(scene)

func on_game_start():
	reload_scene(game_scene)
	
func on_game_end():
	reload_scene(starting_scene)
