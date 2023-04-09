@tool
extends Node2D


const VISUALS_SELECTION: Array[PackedScene] = [
	preload("res://sprites/enemy/spider/spider1.tscn"),
	preload("res://sprites/enemy/spider/spider2.tscn"),
	preload("res://sprites/enemy/spider/spider3.tscn"),
];


func _enter_tree() -> void:
	randomize();
	var visuals = VISUALS_SELECTION.pick_random().instantiate();
	visuals.name = "Visuals";
	add_child(visuals);
