extends Node3D

# Scene setup
@export var player_scene: PackedScene
@export var enemy_scene: PackedScene
@export var enemy_count = 3

func _ready():
	# ゲーム初期化
	setup_level()
	setup_enemies()
	setup_audio()

func setup_level():
	# 基本的なシーン構成
	print("=== 3D ホラーゲーム ===")
	print("WASDで移動、マウスで視点操作")
	print("SpaceでJump、Shiftでスプリント")
	print("ESCでマウス解放")

func setup_enemies():
	# 複数の敵を配置
	for i in range(enemy_count):
		var enemy = Enemy.new()
		add_child(enemy)
		enemy.global_position = Vector3(5 + i * 10, 0, -10)
		print("敵 %d を配置: %s" % [i + 1, enemy.global_position])

func setup_audio():
	# ホラー環境音
	print("環境音: 不気味なBGMと効果音を再生...")

func _process(delta):
	# ゲーム状態更新
	pass