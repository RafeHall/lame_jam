extends Node2D

const WIRE_LAYER: int = 0;
const PORT_LAYER: int = 1;
const COMPONENT_LAYER: int = 2;

@export var tile_size: Vector2i = Vector2i(48, 48);
@export var components: Components = null;

@export var input_port_node: PackedScene = null;
@export var output_port_node: PackedScene = null;

var _graph: DirectedAcyclicGraph = DirectedAcyclicGraph.new();
var _tiles: Array[Dictionary] = [{}, {}, {}];

@onready var _wires: Node2D = $Wires;
@onready var _ports: Node2D = $Ports;
@onready var _components: Node2D = $Components;


class ComponentTile:
	var component: Component;
	var direction: Component.Side = Component.Side.UP;
	var node: Node = null;
	var graph_id: int = -1;
	
	func _init(component: Component, direction: Component.Side, node: Node) -> void:
		self.component = component;
		self.direction = direction;
		self.node = node;


func _ready():
	const TURRET_OFFSET: int = 5;
	
	place_component(Vector2i.ZERO, components.generator);
	
	place_component(Vector2i(TURRET_OFFSET, TURRET_OFFSET), components.turret, Component.Side.RIGHT);
	place_component(Vector2i(TURRET_OFFSET, -TURRET_OFFSET), components.turret, Component.Side.RIGHT);
	place_component(Vector2i(-TURRET_OFFSET, -TURRET_OFFSET), components.turret, Component.Side.LEFT);
	place_component(Vector2i(-TURRET_OFFSET, TURRET_OFFSET), components.turret, Component.Side.LEFT);
	
#	place_wire();


func valid_component_placement(coord: Vector2i, component: Component, direction: Component.Side = Component.Side.UP) -> bool:
	var free_tiles = component.get_port_offsets(direction);
	free_tiles.append(coord);
	
	for offset in free_tiles:
		if has_component_tile(coord + offset) or has_port(coord + offset) or has_wire(coord + offset):
			return false;
	
	return true;


func place_component(coord: Vector2i, component: Component, direction: Component.Side = Component.Side.UP) -> void:
	if valid_component_placement(coord, component, direction):
		var node = component.tile_scene.instantiate();
		node.position = _coord_to_position(coord);
		_components.add_child(node);
		
		var component_tile = ComponentTile.new(component, direction, node);
		component_tile.graph_id = _graph.add_node(component_tile);
		_get_component_tiles()[coord] = component_tile;
		
		var port_offsets = component.get_port_offsets(direction);
		var ports = component.ports;
		for i in range(4):
			var port = ports[i];
			var offset = port_offsets[i];
			var port_node = null;
			match port:
				Component.Port.INPUT:
					port_node = input_port_node.instantiate();
				Component.Port.OUTPUT:
					port_node = output_port_node.instantiate();
			
			if port_node != null:
				port_node.position = _coord_to_position(coord + offset);
				port_node.rotation = Vector2(offset).angle() + PI / 2.0;
				_ports.add_child(port_node);
				
				_get_port_tiles()[coord + offset] = port;


func get_component_tile(coord: Vector2i) -> ComponentTile:
	return _tiles[COMPONENT_LAYER][coord];


func get_port(coord: Vector2i) -> Component.Port:
	return _tiles[PORT_LAYER][coord];


func get_wire(coord: Vector2i) -> Component.Power:
	return _tiles[WIRE_LAYER][coord];


func has_component_tile(coord: Vector2i) -> bool:
	return _tiles[COMPONENT_LAYER].has(coord);


func has_port(coord: Vector2i) -> bool:
	return _tiles[PORT_LAYER].has(coord);


func has_wire(coord: Vector2i) -> bool:
	return _tiles[WIRE_LAYER].has(coord);


#func remove_component(coord: Vector2i) -> void:
#	pass;


func _get_wire_tiles() -> Dictionary:
	return _tiles[WIRE_LAYER];


func _get_port_tiles() -> Dictionary:
	return _tiles[PORT_LAYER];


func _get_component_tiles() -> Dictionary:
	return _tiles[COMPONENT_LAYER];


func _coord_to_position(coord: Vector2i) -> Vector2:
	return Vector2(coord) * Vector2(tile_size);


func _position_to_coord(pos: Vector2) -> Vector2i:
	return Vector2i(pos / Vector2(tile_size));
