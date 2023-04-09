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

@export var spawn_delay_curve: Curve = Curve.new();


var total_weight: float = 0.0;
var current_wave: int = 0;
var first_spawn: bool = false;


func _enter_tree() -> void:
	Global.wave_start_requested.connect(_start_wave);
	
	for enemy in enemy_variants:
		total_weight += enemy.weight;


func _ready() -> void:
	pass;


func _start_wave(wave: int) -> void:
	print(wave);
	current_wave = wave;
	var t = float(wave) / float(curve_intensity_curve_end);
	var enemy_count = int(wave_intensity_curve.sample(t));
	
	var dt = float(wave) / float(curve_intensity_curve_end);
	var max_delay = spawn_delay_curve.sample(dt);
	
	first_spawn = false;
	for i in range(enemy_count):
		var enemy = _select_random_enemy();
		_spawn_enemy(enemy, max_delay);


func _spawn_enemy(enemy: Enemy, max_delay: float) -> void:
	randomize();
	var side = int(randf() > 0.5) * 2.0 - 1.0; # NOTE: Randomly results in -1 or 1
	
	var y_offset = air_center_marker.position.y;
	if enemy.type == Enemy.EnemyType.GROUND:
		y_offset = ground_center_marker.position.y;
	
	var enemy_node = enemy.enemy_scene.instantiate();
	enemy_node.base = enemy;
	enemy_node.position.x = horizontal_offset * side + float(horizontal_distribution * randf_range(-1.0, 1.0));
	enemy_node.position.y = y_offset + float(vertical_distribution) * randf_range(-1.0, 1.0);
	enemy_node.scale.x *= float(side);
	enemy_node.tree_exiting.connect(_check_wave_over);
	
	get_tree().create_timer(randf() * max_delay).timeout.connect(func():
		enemies_node.add_child(enemy_node);
		self.set_deferred("first_spawn", true);
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


func _check_wave_over() -> void:
	# NOTE: Check for 1 because the last node still exists when this is called but it will be 0 afterwards
	if get_tree().get_nodes_in_group("enemies").size() == 1 and first_spawn:
		Global.wave_completed.emit(current_wave);
