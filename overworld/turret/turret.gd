extends Node2D


@export var flipped: bool = false;

@onready var base: Sprite2D = $Base;
@onready var body: Sprite2D = $Body;


func _ready() -> void:
	if flipped:
		base.flip_h = flipped;
		body.flip_h = flipped;
		
		base.position.x = -base.position.x;
		body.position.x = -body.position.x;
		base.offset.x = -base.offset.x;
		body.offset.x = -body.offset.x;
