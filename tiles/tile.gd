class_name Tile
extends Resource

enum Direction {
	UP = 1,
	DOWN = 2,
	LEFT = 4,
	RIGHT = 8,
}

enum Port {
	NONE,
	INPUT,
	OUTPUT,
	INPUT_EXPECTS_1X,
	INPUT_EXPECTS_2X,
	INPUT_EXPECTS_3X,
	INPUT_EXPECTS_4X,
}

@export_flags("Up", "Down", "Left", "Right") var valid_directions: int = Direction.UP;

@export_group("Ports")
@export var north_port: Port = Port.NONE;
@export var east_port: Port = Port.NONE;
@export var south_port: Port = Port.NONE;
@export var west_port: Port = Port.NONE;
