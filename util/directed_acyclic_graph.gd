class_name DirectedAcyclicGraph
extends RefCounted


var _nodes: Dictionary = {};
var _connections: Dictionary = {};

class NodeValue:
	var value: Variant = null;
	var connected_to: Array[int] = [];
	var connected_from: Array[int] = [];
	
	func _init(value):
		self.value = value;


func add_node(value: Variant) -> int:
	var id = hash(value);
	
	var node_value = NodeValue.new(value);
	_nodes[id] = node_value;
	
	return id;


func get_node(id: int) -> Variant:
	if _nodes.has(id):
		return _nodes[id].value;
	else:
		print_debug("Node does not exist");
		return null;


# Returns the edge id or -1 if the edge was invalid
func add_edge(from: int, to: int, value: Variant = null) -> int:
	if !_nodes.has(from) or !_nodes.has(to):
		print_debug("Node does not exist");
		return false;
	
	# NOTE: This needs to be a reference to modify it inside the walk down callback so a normal bool
	#       wouldn't work instead wrapping it in a dictionary is easy enough.
	var _valid: Dictionary = {"valid": true};
	walk_down(to, func(id, value, depth):
		if id == from:
			_valid.valid = false;
	);

	if _valid.valid:
		_nodes[from].connected_to.append(to);
		_nodes[to].connected_from.append(from);
		
		var connection_id = hash(hash(to) + hash(from));
		_connections[connection_id] = value;
		
		return connection_id;
	else:
		printerr("Attempted to add invalid edge");
		return -1;


func remove_node(id: int) -> void:
	pass;


# NOTE: Expensive due to duplicating array
func get_connected_from(id: int) -> Array[int]:
	if _nodes.has(id):
		var node_value: NodeValue = _nodes[id]; 
		return (node_value.connected_from as Array).duplicate();
	else:
		print_debug("Node does not exist");
		return [];


# NOTE: Expensive due to duplicating array
func get_connected_to(id: int) -> Array[int]:
	if _nodes.has(id):
		var node_value: NodeValue = _nodes[id]; 
		return (node_value.connected_to as Array).duplicate();
	else:
		print_debug("Node does not exist");
		return [];


func walk_down(from: int, callback: Callable, depth: int = 0) -> void:
	if !_nodes.has(from):
		print_debug("Node does not exist");
		return;
	
	var node_value: NodeValue = _nodes[from];
	
	callback.call(from, node_value.value, depth);
	
	for id in node_value.connected_to:
		walk_down(id, callback, depth + 1);


func walk_up(from: int, callback: Callable, depth: int = 0) -> void:
	if !_nodes.has(from):
		print_debug("Node does not exist");
		return;
	
	var node_value: NodeValue = _nodes[from];
	
	callback.call(from, node_value.value, depth);
	
	for id in node_value.connected_from:
		walk_up(id, callback, depth + 1);


func clear() -> void:
	_nodes.clear();
