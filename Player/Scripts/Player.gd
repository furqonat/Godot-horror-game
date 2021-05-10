extends KinematicBody


const GRAVITY = -9.8

var root_motion: Transform
var velocity: Vector3 = Vector3.ZERO
var motion: Vector2
var orientation: Transform

var camera_x_root: float = 0.0


onready var model: Spatial = get_node("Player")
onready var animation_tree: AnimationTree = get_node("AnimationTree")
onready var camera_root: Spatial = get_node("CameraRoot")
onready var camera_base: Spatial = get_node("CameraRoot/CameraBase")
onready var camera_view: Camera = get_node("CameraRoot/CameraBase/SpringArm/Camera")


func _ready() -> void:
	orientation = model.global_transform
	orientation.origin = Vector3.ZERO
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	var motion_target = Vector2(
		Input.get_action_strength("left") - Input.get_action_strength("right"),
		Input.get_action_strength("back") - Input.get_action_strength("front")
	)
	motion = motion.linear_interpolate(motion_target, 10 * delta)
	var camera_basis: Basis = camera_view.global_transform.basis
	
	var camera_x: Vector3 = camera_basis.x
	var camera_z: Vector3 = camera_basis.z
	
	camera_x.y = 0
	camera_x = camera_x.normalized()
	camera_z.y = 0
	camera_z = camera_z.normalized()
	
	if motion_target.length() > 0:
		var target = camera_x * motion.x - camera_z * motion.y
		if target.length() > 0.001:
			var q_from = orientation.basis.get_rotation_quat()
			var q_to = Transform().looking_at(target, Vector3.UP).basis.get_rotation_quat()
			orientation.basis = Basis(q_from.slerp(q_to, 10 * delta))
		animation_tree['parameters/walk/blend_position'] = motion.length()
		root_motion = animation_tree.get_root_motion_transform()
	else:
		animation_tree['parameters/walk/blend_position'] = motion.length()
		return
	
	orientation *= root_motion
	var hvel: Vector3 = orientation.origin / delta
	velocity.x = hvel.x
	velocity.z = hvel.z
	velocity.y += GRAVITY * delta
	
	velocity = move_and_slide(velocity, Vector3.UP)
	
	orientation.origin = Vector3.ZERO
	orientation = orientation.orthonormalized()
	
	model.global_transform.basis = orientation.basis
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camera_root.rotate_y(-event.relative.x * 0.002)
		camera_root.orthonormalize()
		camera_x_root += event.relative.y * 0.002
		camera_x_root = clamp(camera_x_root, deg2rad(-40), deg2rad(40))
		camera_base.rotation.x = camera_x_root
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

