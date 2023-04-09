class_name Components
extends Resource


@export var generator: Component = preload("res://components/generator/generator.tres");
@export var capacitor: Component = preload("res://components/capacitor/capacitor.tres");
@export var turret: Component = preload("res://components/turret/turret.tres");
@export var straight_wire: Component = preload("res://components/wires/straight_wire.tres");


func get_as_array() -> Array[Component]:
	return [
		generator,
		capacitor,
		turret,
		straight_wire,
	];
