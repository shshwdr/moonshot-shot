extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func show_moon():
	$advertisement/moon_thumbup.visible = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$advertisement/moon_thumbup.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
