extends Node

signal current_component_changed(new_component: Component);
signal focused_component_changed(new_component: Component);
signal wave_start_requested(wave: int);
signal wave_completed(wave: int);

var money: int = 1000;
var health: int = 100;
var wave: int = 1;

var current_component: Component = null:
	set(value):
		current_component = value;
		current_component_changed.emit(value);


var focused_component: Component = null:
	set(value):
		focused_component = value;
		focused_component_changed.emit(value);


func get_wave_progress() -> float:
	return 0.0;


func request_wave_start() -> void:
	wave_start_requested.emit(wave);
