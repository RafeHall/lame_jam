class_name EnemyScript
extends Node2D


var base: Enemy = null;


func _enter_tree() -> void:
	if base == null:
		queue_free();


func _physics_process(delta: float) -> void:
	position.x += base.speed * delta * -scale.x;
