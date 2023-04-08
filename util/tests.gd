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
	
	graph.add_edge(a, b);
	graph.add_edge(b, c);
	graph.add_edge(c, d);
	graph.add_edge(b, e);
	graph.add_edge(e, f);
	graph.add_edge(f, g);
	graph.add_edge(g, h);
	graph.add_edge(d, h);
	graph.add_edge(h, a);
	
	graph.walk_down(a, func(id, value, depth):
		print(value);
	);
