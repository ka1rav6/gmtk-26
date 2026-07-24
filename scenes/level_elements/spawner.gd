extends Node2D

@export var toSpawn : PackedScene
@export var spawnEvery : float

func _ready() -> void:
	var timer = Timer.new()
	timer.wait_time = spawnEvery
	timer.autostart = true
	timer.timeout.connect(_spawn)
	add_child(timer)

func _spawn() -> void:
	var instance = toSpawn.instantiate()
	instance.global_position = global_position
	get_parent().add_child(instance)
