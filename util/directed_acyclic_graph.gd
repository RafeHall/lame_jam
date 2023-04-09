class_name DirectedAcyclicGraph
extends RefCounted


var _nodes: Dictionary = {};
var _edges: Dictionary = {};

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


func get_edge(from: int, to: int) -> Variant:
	var id = get_edge_id(from, to);
	if not _edges.has(id):
		print_debug("Edge does not exists");
		return null;
	else:
		return _edges[id];


func get_edge_by_id(id: int) -> Variant:
	if not _edges.has(id):
		print_debug("Edge does not exists");
		return null;
	else:
		return _edges[id];


func valid_edge(from: int, to: int) -> bool:
	# NOTE: This needs to be a reference to modify it inside the walk down callback so a normal bool
	#       wouldn't work instead wrapping it in a dictionary is easy enough.
	var _valid: Dictionary = {"valid": true};
	walk_down(to, func(id, value, depth):
		if id == from:
			_valid.valid = false;
	);
	
	return _valid.valid;


# Returns the edge id or -1 if the edge was invalid or node does not exist
func add_edge(from: int, to: int, value: Variant = null) -> int:
	if !_nodes.has(from) or !_nodes.has(to):
		print_debug("Node does not exist");
		return -1;
	
	var valid = valid_edge(from, to);
	
	if valid:
		_nodes[from].connected_to.append(to);
		_nodes[to].connected_from.append(from);
		
		var edge_id = get_edge_id(from, to);
		_edges[edge_id] = value;
		
		return edge_id;
	else:
		print_debug("Attempted to add invalid edge");
		return -1;


func remove_node(node: int) -> void:
	if !_nodes.has(node):
		print_debug("Node does not exist");
		return;
	
	var from = node;
	
	for to in get_connected_to(from):
		remove_edge(from, to);


func remove_edge(from: int, to: int) -> void:
	var id = get_edge_id(from, to);
	if not _edges.has(id):
		print_debug("Edge does not exists");
		return;
	_edges.erase(id);


func remove_edge_by_id(id: int) -> void:
	if not _edges.has(id):
		print_debug("Edge does not exists");
		return;
	_edges.erase(id);


func get_edge_id(from: int, to: int) -> int:
	return hash(hash(to) + hash(from));


# NOTE: "Expensive" due to duplicating array
func get_connected_from(id: int) -> Array[int]:
	if _nodes.has(id):
		var node_value: NodeValue = _nodes[id]; 
		return (node_value.connected_from as Array).duplicate();
	else:
		print_debug("Node does not exist");
		return [];


# NOTE: "Expensive" due to duplicating array
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
