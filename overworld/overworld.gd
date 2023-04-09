extends Node2D


@onready var enemies_node: Node = $Enemies;
@onready var ground_center_marker: Marker2D = $GroundCenter;
@onready var air_center_marker: Marker2D = $AirCenter;

@export var enemy_variants: Array[Enemy] = [];
@export var wave_intensity_curve: Curve = Curve.new();
@export var curve_intensity_curve_end: int = 25;


func _enter_tree() -> void:
	Global.wave_start_requested.connect(_start_wave);
	
	for i in range(25):
		_start_wave(i);


func _start_wave(wave: int) -> void:
	var t = float(wave) / float(curve_intensity_curve_end);
	var enemies = int(wave_intensity_curve.sample(t));
	
	print(enemies);
