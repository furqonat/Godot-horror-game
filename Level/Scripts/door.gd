extends Spatial

signal door_is_open(status)

var is_open: bool = false
var door_entered: bool = false

onready var animation_player = get_node("AnimationPlayer")
onready var area_from = get_node("Door_Group/DoorFrame001/Door001/Front")
onready var door = get_node("Door_Group/DoorFrame001/Door001")


func _ready() -> void:
	area_from.connect("body_entered", self, "area_from_entered")
	self.connect("door_is_open", self, "door_open")
	
func _physics_process(delta: float) -> void:
	if is_open and Input.is_action_just_pressed("lock_door"):
			if door_entered:
				animation_player.play("Close")
			else:
				return
	
	
func area_from_entered(body) -> void:
	if body is KinematicBody:
		door_entered = true
		if is_open:
			return
		else:
			animation_player.play("Open")
	else:
		door_entered = false

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "Open":
		is_open = true
	else:
		is_open = false


func _on_Front_body_exited(body: Node) -> void:
	door_entered = false
