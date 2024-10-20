class_name ComponentScript
extends RefCounted


# Gets called for every input to the tile
func input(side: Component.Side, power: int) -> void:
	pass;


# Gets called for every output to the tile
func output(side: Component.Side) -> int:
	return 0;


# Gets called before inputs and outputs to clear or update the state in some way
func tick(elapsed: int) -> void:
	pass;
