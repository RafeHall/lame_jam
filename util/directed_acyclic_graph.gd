class_name DirectedAcyclicGraph
extends RefCounted


var _nodes: Dictionary = {};

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
		return null;


# Returns whether the edge was valid and was added
func add_edge(from: int, to: int) -> bool:
	if !_nodes.has(from) or !_nodes.has(to):
		return false;
	
	var valid: bool = true;
	
	walk_down(to, func(id, value, depth):
		if id == from:
			valid = false;
	);
	
	if valid:
		_nodes[from].connected_to.append(to);
		_nodes[to].connected_from.append(from);
	
	return valid;


# NOTE: Expensive due to duplicating array
func get_connected_from(id: int) -> Array[int]:
	if _nodes.has(id):
		var node_value: NodeValue = _nodes[id]; 
		return (node_value.connected_from as Array).duplicate();
	else:
		return [];


# NOTE: Expensive due to duplicating array
func get_connected_to(id: int) -> Array[int]:
	if _nodes.has(id):
		var node_value: NodeValue = _nodes[id]; 
		return (node_value.connected_to as Array).duplicate();
	else:
		return [];


func walk_down(from: int, callback: Callable, depth: int = 0) -> void:
	if !_nodes.has(from):
		return;
	
	var node_value: NodeValue = _nodes[from];
	
	callback.call(from, node_value.value, depth);
	
	for id in node_value.connected_to:
		walk_down(id, callback, depth + 1);


func walk_up(from: int, callback: Callable, depth: int = 0) -> void:
	if !_nodes.has(from):
		return;
	
	var node_value: NodeValue = _nodes[from];
	
	callback.call(from, node_value.value, depth);
	
	for id in node_value.connected_from:
		walk_up(id, callback, depth + 1);


func clear() -> void:
	_nodes.clear();
