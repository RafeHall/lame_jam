class_name CircuitBoard
extends Node2D

const PORT_LAYER: int = 0;
const COMPONENT_LAYER: int = 1;

const ANGLE_OFFSET: float = PI / 2.0;

@export var tile_size: Vector2i = Vector2i(48, 48);
@export var board_size: Vector2i = Vector2i(11, 11);
@export var components: Components = null;

@export var input_port_node: PackedScene = null;
@export var output_port_node: PackedScene = null;

var _graph: DirectedAcyclicGraph = DirectedAcyclicGraph.new();
var _tiles: Array[Dictionary] = [{}, {}];

@onready var _ports: Node2D = $Ports;
@onready var _components: Node2D = $Components;
@onready var _marker_nodes: Node2D = $MarkerNodes;
@onready var _marker_ports: Node2D = $MarkerNodes/MarkerPorts;

#@onready var _marker_component: Component = components.capacitor;

var _marker: Node = null;
var _marker_in_ports: Array = [];
var _marker_out_ports: Array = [];
var _marker_direction: Component.Side = Component.Side.UP;

@export var valid_image_straight: Texture2D = preload("res://sprites/player/ui/line2.png");
@export var invalid_image_straight: Texture2D = preload("res://sprites/player/ui/line1.png");

@export var valid_image_bend: Texture2D = preload("res://sprites/player/ui/line2.png");
@export var invalid_image_bend: Texture2D = preload("res://sprites/player/ui/line1.png");


class ComponentTile extends RefCounted:
	var component: Component;
	var direction: Component.Side = Component.Side.UP;
	var node: Node = null;
	var graph_id: int = -1;
	var ports: Array[PortTile] = [];
	var locked: bool = false;
	
	func _init(component: Component, direction: Component.Side, node: Node, ports: Array[PortTile], locked: bool) -> void:
		self.component = component;
		self.direction = direction;
		self.node = node;
		self.ports = ports;
		self.locked = locked;


class PortTile extends RefCounted:
	var type: Component.Port;
	var direction: Component.Side = Component.Side.UP;
	var node: Node = null;
	var coord: Vector2i = Vector2i.ZERO;
	
	func _init(type: Component.Port, direction: Component.Side, node: Node, coord: Vector2i) -> void:
		self.type = type;
		self.direction = direction;
		self.node = node;
		self.coord = coord;


func _ready():
	const TURRET_OFFSET: int = 5;
	
	valid_component_placement(Vector2i(0, -1), components.turret, Component.Side.UP);
	
	place_component(Vector2i.ZERO, components.generator, Component.Side.UP, true);
	
	place_component(Vector2i(TURRET_OFFSET, TURRET_OFFSET), components.turret, Component.Side.RIGHT, true);
	place_component(Vector2i(TURRET_OFFSET, -TURRET_OFFSET), components.turret, Component.Side.RIGHT, true);
	place_component(Vector2i(-TURRET_OFFSET, -TURRET_OFFSET), components.turret, Component.Side.LEFT, true);
	place_component(Vector2i(-TURRET_OFFSET, TURRET_OFFSET), components.turret, Component.Side.LEFT, true);
	
	place_component(Vector2i(0, -2), components.capacitor, Component.Side.UP);
	
#	place_wire(Vector2i(0, 1), true, Component.Side.RIGHT);
	
	_marker = Sprite2D.new();
#	_marker.scale = Vector2(1.333, 1.333); # NOTE: This is to fit the testing wire textures
	_marker_nodes.add_child(_marker);
	
	for side in Component.Side.values():
		var in_port = input_port_node.instantiate();
		var out_port = output_port_node.instantiate();
		
		var offset = Vector2(Component.side_to_offset(side));
		var rot = offset.angle() + ANGLE_OFFSET;
		
		in_port.visible = false;
		out_port.visible = false;
		
		in_port.position += _coord_to_position(offset);
		out_port.position += _coord_to_position(offset);
		
		in_port.rotation = rot;
		out_port.rotation = rot;
		
		_marker_in_ports.append(in_port);
		_marker_out_ports.append(out_port);
		
		_marker_ports.add_child(in_port);
		_marker_ports.add_child(out_port);


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_update_marker();
	elif event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_E:
				_rotate_marker(1);
				_update_marker();
			elif event.keycode == KEY_Q:
				_rotate_marker(-1);
				_update_marker();
	elif event is InputEventMouseButton:
		if event.pressed:
			var mouse_position = get_local_mouse_position();
			var coord = _position_to_coord(mouse_position);
			if event.button_index == MOUSE_BUTTON_LEFT:
				place_component(coord, Global.current_component, _marker_direction);
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				remove_component(coord);
			_update_marker();


func valid_component_placement(coord: Vector2i, component: Component, direction: Component.Side = Component.Side.UP) -> bool:
	if not valid_coord(coord):
		return false;
	
	# NOTE: Check if we're placing a component onto another component
	if has_component_tile(coord):
		return false;
	
	for i in range(4):
		var global_side = Component.index_to_side(i);
		var global_offset = Component.side_to_offset(global_side);
		
		# NOTE: Skip checks if no tile exists neighboring on that side
		if not has_component_tile(coord + global_offset):
			continue;
		
		var neighbor: ComponentTile = get_component_tile(coord + global_offset);
		var neighbor_rot = Component.side_to_index(neighbor.direction);
		
		var rot = Component.side_to_index(direction);
		
		var rotated_port = component.ports[(i + rot) % 4];
		var neighbor_rotated_port = neighbor.component.ports[neighbor_rot];
		
		# NOTE: Skip port checks if no port exists or is a universal port
		if rotated_port != Component.Port.INPUT or rotated_port != Component.Port.OUTPUT:
			continue;
		
		if neighbor_rotated_port != Component.Port.INPUT or neighbor_rotated_port != Component.Port.OUTPUT:
			continue;
		
		# NOTE: Checks if an input is connected to an output
		if not rotated_port != neighbor_rotated_port:
			return false;
	
	# TODO: Verify with the graph that this connection is not cyclic
	
	
	return true;


func place_component(coord: Vector2i, component: Component, direction: Component.Side = Component.Side.UP, locked = false) -> void:
	if valid_component_placement(coord, component, direction):
		var node = component.tile_scene.instantiate();
		node.position = _coord_to_position(coord);
		node.rotation = Vector2(Component.side_to_offset(direction)).angle() + ANGLE_OFFSET;
		_components.add_child(node);
		
		var component_ports: Array[PortTile] = [];
		var port_offsets = component.get_port_offsets(direction);
		var ports = component.ports;
		for i in range(4):
			var port = ports[i];
			var offset = port_offsets[i];
			
			var side = Component.index_to_side(i);
			var rotation_amount = Component.side_to_index(direction);
			var port_direction = Component.rotate_side(side, rotation_amount);
			
			var port_node = null;
			match port:
				Component.Port.INPUT:
					port_node = input_port_node.instantiate();
				Component.Port.OUTPUT:
					port_node = output_port_node.instantiate();
			
			if port_node != null:
				port_node.position = _coord_to_position(coord + offset);
				port_node.rotation = Vector2(offset).angle() + ANGLE_OFFSET;
				_ports.add_child(port_node);
				
				var port_tile = PortTile.new(port, port_direction, port_node, coord + offset);
				component_ports.append(port_tile);
				_get_port_tiles()[coord + offset] = port_tile;
		
		var component_tile = ComponentTile.new(component, direction, node, component_ports, locked);
		component_tile.graph_id = _graph.add_node(component_tile);
		_get_component_tiles()[coord] = component_tile;


func remove_component(coord: Vector2i) -> void:
	if not has_component_tile(coord):
		return;
	
	var tile_component = get_component_tile(coord);
	if tile_component.locked:
		return;
	
	tile_component.node.queue_free();
	for port in tile_component.ports:
		port.node.queue_free();
		_get_port_tiles().erase(port.coord);
	
	_graph.remove_node(tile_component.graph_id);
	_get_component_tiles().erase(coord);


func valid_coord(coord: Vector2i) -> bool:
	if coord.x > (board_size.x - 1) / 2:
		return false;
	if coord.y > (board_size.y - 1) / 2:
		return false;
	if coord.y < -(board_size.y - 1) / 2:
		return false;
	if coord.x < -(board_size.x - 1) / 2:
		return false;
	return true;


func get_component_tile(coord: Vector2i) -> ComponentTile:
	return _tiles[COMPONENT_LAYER][coord];


func get_port(coord: Vector2i) -> PortTile:
	return _tiles[PORT_LAYER][coord];


func has_component_tile(coord: Vector2i) -> bool:
	return _tiles[COMPONENT_LAYER].has(coord);


func has_port(coord: Vector2i) -> bool:
	return _tiles[PORT_LAYER].has(coord);


func _update_marker() -> void:
	if Global.current_component == null:
		return;
	
	var mouse_position = get_local_mouse_position();
	
	var tile_coord = _position_to_coord(mouse_position);
	var pos = _coord_to_position(tile_coord);
	
	_marker_nodes.position = pos;
	
	for i in range(4):
		var port = Global.current_component.ports[i];
		
		if port == Component.Port.INPUT:
			_marker_in_ports[i].visible = true;
		else:
			_marker_in_ports[i].visible = false;
		
		if port == Component.Port.OUTPUT:
			_marker_out_ports[i].visible = true;
		else:
			_marker_out_ports[i].visible = false;
	
	var rot = Vector2(Component.side_to_offset(_marker_direction)).angle() + ANGLE_OFFSET;
	if Global.current_component.visuals_rotate:
		_marker_nodes.rotation = rot;
		_marker_ports.rotation = 0;
	else:
		_marker_nodes.rotation = 0;
		_marker_ports.rotation = rot;
	
	var valid = valid_component_placement(tile_coord, Global.current_component, _marker_direction);
	_marker.texture = Global.current_component.icon;
	
	if not valid_coord(tile_coord):
		_marker_nodes.modulate = Color.TRANSPARENT;
	elif valid:
		_marker_nodes.modulate = Color.GREEN;
	else:
		_marker_nodes.modulate = Color.RED;


func _rotate_marker(by: int) -> void:
	var new_index = posmod(Component.side_to_index(_marker_direction) + by, 4);
	_marker_direction = Component.index_to_side(new_index);
	
	if not Component.rotations_have(Global.current_component.valid_rotations, _marker_direction):
		_rotate_marker(by);


func _get_port_tiles() -> Dictionary:
	return _tiles[PORT_LAYER];


func _get_component_tiles() -> Dictionary:
	return _tiles[COMPONENT_LAYER];


func _coord_to_position(coord: Vector2i) -> Vector2:
	return Vector2(coord) * Vector2(tile_size);


func _position_to_coord(pos: Vector2) -> Vector2i:
	var new_pos = pos + Vector2(tile_size) / 2.0;
	
	var x = int(floor(new_pos.x / float(tile_size.x)));
	var y = int(floor(new_pos.y / float(tile_size.y)));
	
	return Vector2i(x, y);
