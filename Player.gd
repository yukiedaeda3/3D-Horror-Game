extends CharacterBody3D

# Movement
@export var speed = 5.0
@export var sprint_speed = 8.0
@export var jump_force = 5.0
@export var gravity = -9.8

# Camera
@export var mouse_sensitivity = 0.003
var camera_3d: Camera3D
var head: Node3D

# State
var is_sprinting = false
var current_speed = speed

func _ready():
	# カメラセットアップ
	head = Node3D.new()
	add_child(head)
	head.position = Vector3(0, 0.6, 0)  # 頭の高さ
	
	camera_3d = Camera3D.new()
	head.add_child(camera_3d)
	
	# マウス入力をキャプチャ
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# 移動入力
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# スプリント
	if Input.is_action_pressed("ui_accept"):
		is_sprinting = true
		current_speed = sprint_speed
	else:
		is_sprinting = false
		current_speed = speed
	
	# 移動適用
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	# 重力
	velocity.y += gravity * delta
	
	# ジャンプ
	if Input.is_action_just_pressed("ui_focus_next") and is_on_floor():
		velocity.y = jump_force
	
	move_and_slide()

func _input(event):
	# マウス視点
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(-event.relative.x * mouse_sensitivity)
		camera_3d.rotate_object_local(Vector3.RIGHT, -event.relative.y * mouse_sensitivity)
		
		# カメラの回転制限
		var camera_rot = camera_3d.rotation.x
		if camera_rot > PI / 2:
			camera_3d.rotation.x = PI / 2
		elif camera_rot < -PI / 2:
			camera_3d.rotation.x = -PI / 2
	
	# ESCキーでマウス解放
	if Input.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
