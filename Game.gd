extends Spatial

onready var player = get_node("Player")

func _ready() -> void:
	player.connect("body_hit", self, "get_health")
	
	
func get_health(health) -> void:
	print(health)
