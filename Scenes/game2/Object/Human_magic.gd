extends Human


var strong_max_health = 5
var has_shield = false
onready var shield = $shield



func can_block_thunder():
	return has_shield
func stop():
	.stop()
	shield.visible = true
	has_shield = true
	shield.play()
	
func block_thunder():
	has_shield = false
	shield.visible = false

# Called when the node enters the scene tree for the first time.
func _ready():
	max_health = strong_max_health
	health = strong_max_health
	shield.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
