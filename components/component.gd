class_name Component
extends Resource

enum Side {
	UP = 1,
	RIGHT = 2,
	DOWN = 4,
	LEFT = 8,
}

enum Port {
	NONE,
	INPUT,
	OUTPUT,
	IN_OUT,
}

enum Power {
	NONE = -1,
	ZERO = 0,
	LOW = 1,
	MEDIUM = 2,
	HIGH = 3,
	FULL = 4,
}

@export var tile_script: Script = null;
@export var tile_scene: PackedScene = null;
@export var visuals_rotate: bool = false;
@export_flags("Up:1", "Down:4", "Left:8", "Right:2") var valid_rotations: int = Side.UP;

@export_group("Shop")
@export var icon: Texture2D = null;
@export var buyable: bool = true;
@export var cost: int = 250;

@export_group("Ports")
@export var north_port: Port = Port.NONE;
@export var east_port: Port = Port.NONE;
@export var south_port: Port = Port.NONE;
@export var west_port: Port = Port.NONE;

var ports: Array[Port]:
	get:
		return [north_port, east_port, south_port, west_port];


func get_port_offsets(rotation: Component.Side) -> Array[Vector2i]:
	var offsets: Array[Vector2i] = [];
	offsets.resize(4);
	
	for i in range(4):
		var port = ports[i];
		var side = index_to_side(i);
		var rotation_amount = side_to_index(rotation);
		var new_side = rotate_side(side, rotation_amount);
		var offset = side_to_offset(new_side);
		offsets[i] = offset;
	
	return offsets;


static func rotate_side(side: Component.Side, amount: int) -> Component.Side:
	if amount <= 0:
		return side;
	
	var new_side = Side.UP;
	
	match side:
		Side.UP:
			new_side = Side.RIGHT;
		Side.RIGHT:
			new_side = Side.DOWN;
		Side.DOWN:
			new_side = Side.LEFT;
		Side.RIGHT:
			new_side = Side.UP;
	
	return rotate_side(new_side, amount - 1);


static func side_to_index(side: Component.Side) -> int:
	match side:
		Side.UP:
			return 0;
		Side.RIGHT:
			return 1;
		Side.DOWN:
			return 2;
		Side.LEFT:
			return 3;
	return -1;


static func index_to_side(index: int) -> Component.Side:
	match index:
		0:
			return Side.UP;
		1:
			return Side.RIGHT;
		2:
			return Side.DOWN;
		3:
			return Side.LEFT;
		_:
			return Side.UP
	return Side.UP;


static func rotations_have(rotations: int, side: Component.Side) -> bool:
	return rotations & int(side) == int(side);


static func side_to_offset(side: Component.Side) -> Vector2i:
	match side:
		Side.UP:
			return Vector2i.UP;
		Side.RIGHT:
			return Vector2i.RIGHT;
		Side.DOWN:
			return Vector2i.DOWN;
		Side.LEFT:
			return Vector2i.LEFT;
	return Vector2i.ZERO;


static func offset_to_side(offset: Vector2i) -> Component.Side:
	match offset:
		Vector2i.UP:
			return Side.UP;
		Vector2i.RIGHT:
			return Side.RIGHT;
		Vector2i.DOWN:
			return Side.DOWN;
		Vector2i.LEFT:
			return Side.LEFT;
	return Side.UP;


static func opposite_side(side: Component.Side) -> Component.Side:
	match side:
		Side.UP:
			return Side.DOWN;
		Side.RIGHT:
			return Side.LEFT;
		Side.DOWN:
			return Side.UP;
		Side.LEFT:
			return Side.RIGHT;
	return Side.UP;
