extends RichTextLabel
# TODO: This is supposed to show help for the current component or the default
#       when not hovering over any in either the buy menu or on the circuit board

@export_multiline var default_text: String = "[outline_size=2][outline_color=black][b]Left Click[/b] to place component.
[b]Right Click[/b] to sell component for half the cost.
[b]E[/b] or [b]Scroll Down[/b] to rotate component clockwise.
[b]Q[/b] or [b]Scroll Up[/b] to rotate comonent counter-clockwise.
[/outline_color][/outline_size]";


func _enter_tree() -> void:
	Global.current_component_changed.connect(_current_component_changed);


func _current_component_changed(new_component: Component):
	if new_component == null:
		text = default_text;
	else:
		text = new_component.description;
