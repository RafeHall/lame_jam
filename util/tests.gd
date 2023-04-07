@tool
extends EditorScript


func _run():
	var graph = DirectedAcyclicGraph.new();
	
	var a = graph.add_node("A");
	var b = graph.add_node("B");
	var c = graph.add_node("C");
	var d = graph.add_node("D");
	var e = graph.add_node("E");
	var f = graph.add_node("F");
	var g = graph.add_node("G");
	var h = graph.add_node("H");
	
	if not graph.add_edge(a, b):
		printerr("A->B");
	
	if not graph.add_edge(b, c):
		printerr("B->C");
	
	if not graph.add_edge(c, d):
		printerr("C->D");
	
	
	if not graph.add_edge(b, e):
		printerr("B->E");
	
	if not graph.add_edge(e, f):
		printerr("E->F");
	
	if not graph.add_edge(f, g):
		printerr("F->G");
	
	
	if not graph.add_edge(g, h):
		printerr("G->H");
	
	if not graph.add_edge(d, h):
		printerr("D->H");
	
	graph.walk_down(a, func(id, value, depth):
		print(value);
	);
