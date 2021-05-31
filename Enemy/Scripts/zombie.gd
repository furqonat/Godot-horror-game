extends KinematicBody

var speed = 1.2
var start_position


var m = SpatialMaterial.new()

onready var target = get_parent().get_parent().get_node("Player")
onready var model = get_node("zombie")
onready var nav = get_parent().get_parent().get_node("Navigation")

var path = []
var dir: Vector3 = Vector3.ZERO

func _ready() -> void:
	
	m.flags_unshaded = true
	m.flags_use_point_size = true
	m.albedo_color = Color.white
	
	start_position = global_transform.origin
	

func _physics_process(delta) -> void:
	var next_size = speed * delta
	if path.size() > 0:
		var destination = path[0]
		dir = destination - global_transform.origin
		if next_size > dir.length():
			next_size = dir.length()
			path.remove(0)
		if self.global_transform.origin.distance_to(target.global_transform.origin) < 3:
			$animation_tree['parameters/walk/blend_position'] = 1
			if self.global_transform.origin.distance_to(target.global_transform.origin) < 0.7:
				$animation_tree['parameters/walk/blend_position'] = 0
		dir = move_and_slide(dir.normalized() * speed, Vector3.UP)
		dir.y = 0
		if dir:
			var look =  dir.normalized() + global_transform.origin
			look_at(look, Vector3.UP)
	else:
		$animation_tree['parameters/walk/blend_position'] = 0
		
func draw_path(path_array) -> void:
	var im = get_parent().get_parent().get_node("draw")
	im.set_material_override(m)
	im.clear()
	im.begin(Mesh.PRIMITIVE_POINTS, null)
	im.add_vertex(path_array[0])
	im.add_vertex(path_array[path_array.size() - 1])
	im.end()
	im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	for x in path:
		im.add_vertex(x)
	im.end()



func _on_Player_position_now(position: Vector3) -> void:
	if global_transform.origin.distance_to(position) < 3:
		path = nav.get_simple_path(global_transform.origin, target.global_transform.origin, true)
		draw_path(path)
	else:
		if start_position == global_transform.origin:
			path = []
		else:
			path = nav.get_simple_path(global_transform.origin, start_position, true)
			draw_path(path)
