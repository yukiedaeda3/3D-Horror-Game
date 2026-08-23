extends CharacterBody3D

# Enemy properties
@export var speed = 3.0
@export var detection_range = 15.0
@export var attack_range = 2.0
@export var attack_cooldown = 2.0
@export var health = 30

# References
var player: Node3D
var animation_player: AnimationPlayer

# State
var state = "idle"  # idle, chase, attack, dead
var last_attack_time = 0.0
var target_position = Vector3.ZERO

func _ready():
	player = get_tree().root.get_node("Main/Player")
	animation_player = AnimationPlayer.new()
	add_child(animation_player)

func _physics_process(delta):
	if state == "dead":
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# State machine
	if distance_to_player < detection_range:
		if distance_to_player < attack_range:
			state = "attack"
		else:
			state = "chase"
	else:
		state = "idle"
	
	# Execute state
	match state:
		"idle":
			idle_behavior()
		"chase":
			chase_behavior(delta)
		"attack":
			attack_behavior(delta)
	
	move_and_slide()

func idle_behavior():
	# ゆっくり移動または待機
	velocity = velocity.lerp(Vector3.ZERO, 0.1)

func chase_behavior(delta):
	# プレイヤーに向かって移動
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	
	# プレイヤーの方を向く
	look_at(player.global_position, Vector3.UP)

func attack_behavior(delta):
	# 停止してプレイヤーを見つめる
	velocity = Vector3.ZERO
	look_at(player.global_position, Vector3.UP)
	
	# 攻撃
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_attack_time > attack_cooldown:
		perform_attack()
		last_attack_time = current_time

func perform_attack():
	# ジャンプスケア効果: スクリーン上に敵を表示
	print("敵が襲い掛かった！ジャンプスケア！")
	
	# ダメージカメラシェイク
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# プレイヤーに向かって一気に近づく
	var player_camera = player.get_node("Head/Camera3D")
	var original_pos = global_position
	
	tween.tween_property(self, "global_position", player_camera.global_position + Vector3(0, -0.5, 0), 0.3)
	tween.tween_callback(func():
		# スケアアニメーション後に戻す
		global_position = original_pos
	)

func take_damage(damage: int):
	health -= damage
	if health <= 0:
		die()

func die():
	state = "dead"
	visible = false
	queue_free()

func _on_entered_player_range():
	# プレイヤーを検知時のコールバック
	print("敵がプレイヤーを発見！")