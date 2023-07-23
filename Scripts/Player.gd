extends CharacterBody3D
class_name Player


@export_category("Rotation")
@export_range(-360, 360) var forward_rotation: float = 0
@export_range(-360, 360) var back_rotation: float = 0

@export_range(-360, 360) var left_rotation: float = 0
@export_range(-360, 360) var right_rotation: float = 0


@export_category("Movement")
@export var SPEED = 1.0
@export var ROTATE_SPEED = 1
@export var JUMP_VELOCITY = 4.5

@export_category("Extra")
@export var enable_jump = false

@export_category("Animation")
@export var anim_player: AnimationPlayer

@export_category("Requirements")
@export var model: MeshInstance3D

@export_group("Camera")
@export var camera: Camera3D
@export var camera_parent: Node3D


var _previous_mouse_pos = Vector2.ZERO
var _is_zooming = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		
		if not important_animation_playing():
			change_animation("fall")
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		change_animation("jump")
	
	rotation.y = 0
	
	if Input.is_action_pressed("rotate_left"):
		camera_parent.rotate_y(-ROTATE_SPEED * delta)
	elif Input.is_action_pressed("rotate_right"):
		camera_parent.rotate_y(ROTATE_SPEED * delta)
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if direction.x != 0:
			direction.z = 0
		elif direction.z != 0:
			direction.x = 0
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		if direction.x != 0:
			if direction.x == -1:
				model.rotation_degrees.y = left_rotation
			elif direction.x == 1:
				model.rotation_degrees.y = right_rotation
		elif direction.z != 0:
			if direction.z == -1:
				model.rotation_degrees.y = forward_rotation
			elif direction.z == 1:
				model.rotation_degrees.y = back_rotation
		
		if is_on_floor():
			change_animation("move")
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
		if is_on_floor():
			change_animation("idle")

	move_and_slide()


# Handle zoom and and camera moving
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_is_zooming = event.is_pressed()
	
	if event is InputEventMouseMotion:
		if _is_zooming:
			var scroll_delta = event.position
			var new_fov = camera.fov
			
			if scroll_delta.y < _previous_mouse_pos.y:
				new_fov -= 1
			else:
				new_fov += 1
			
			camera.fov = clamp(new_fov, 20, 100)
			
			_previous_mouse_pos = event.position


## If an important animation is playing
func important_animation_playing() -> bool:
	return false


## Plays an animation, Return is if the animation can be played
func change_animation(animation: String) -> bool:
	if anim_player.current_animation == animation or important_animation_playing():
		return false
	
	anim_player.play("RESET")
	anim_player.play(animation)
	
	return true
