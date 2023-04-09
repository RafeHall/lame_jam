extends Node2D


@onready var enemies_node: Node = $Enemies;
@onready var ground_center_marker: Marker2D = $GroundCenter;
@onready var air_center_marker: Marker2D = $AirCenter;

@export_group("Intensity")
@export var enemy_variants: Array[Enemy] = [];
@export var wave_intensity_curve: Curve = Curve.new();
@export var curve_intensity_curve_end: int = 25;

@export_group("Spawning")
@export var horizontal_offset: int = 720 * 2;

@export var horizontal_distribution: int = 50;
@export var vertical_distribution: int = 50;

@export var spawn_max_delay: float = 15.0;


var total_weight: float = 0.0;


func _enter_tree() -> void:
	Global.wave_start_requested.connect(_start_wave);


func _ready() -> void:
	for enemy in enemy_variants:
		total_weight += enemy.weight;
	
#	for i in range(25):
	_start_wave(10);


func _start_wave(wave: int) -> void:
	var t = float(wave) / float(curve_intensity_curve_end);
	var enemy_count = int(wave_intensity_curve.sample(t));
	
	for i in range(enemy_count):
		var enemy = _select_random_enemy();
		_spawn_enemy(enemy);


func _spawn_enemy(enemy: Enemy) -> void:
	var side = int(randf() > 0.5) * 2.0 - 1.0; # NOTE: Randomly results in -1 or 1
	
	var y_offset = air_center_marker.position.y;
	if enemy.type == Enemy.EnemyType.GROUND:
		y_offset = ground_center_marker.position.y;
	
	var enemy_node = enemy.enemy_scene.instantiate();
	enemy_node.base = enemy;
	enemy_node.position.x = horizontal_offset * side + float(horizontal_distribution * randf_range(-1.0, 1.0));
	enemy_node.position.y = y_offset + float(vertical_distribution) * randf_range(-1.0, 1.0);
	enemy_node.scale.x *= float(side);
	
	get_tree().create_timer(randf() * spawn_max_delay).timeout.connect(func():
		enemies_node.add_child(enemy_node);
	);


func _select_random_enemy() -> Enemy:
	randomize();
	
	var rand = randf_range(0.0, total_weight);
	var offset = 0.0;
	for enemy in enemy_variants:
		if rand <= enemy.weight + offset:
			return enemy;
		else:
			offset += enemy.weight;
	
	return enemy_variants.pick_random();


func _on_tower_area_area_entered(area: Area2D) -> void:
	var parent = area.get_parent();
	if is_instance_of(parent, EnemyScript):
		parent.queue_free();
		Global.health -= 1;
