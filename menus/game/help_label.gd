extends RichTextLabel
# TODO: This is supposed to show help for the current component or the default
#       when not hovering over any in either the buy menu or on the circuit board

@export_multiline var default_text: String = "[b]Left Click[/b] to place component.
[b]Right Click[/b] to sell component for half the cost.
[b]E[/b] or [b]Scroll Down[/b] to rotate component clockwise.
[b]Q[/b] or [b]Scroll Up[/b] to rotate component counter-clockwise.";


func _enter_tree() -> void:
	Global.focused_component_changed.connect(_focused_component_changed);


func _focused_component_changed(focused: Component):
	if focused == null:
		text = default_text;
	else:
		text = focused.description;
	
	$AnimationPlayer.stop(true);
	$AnimationPlayer.play("noisefx")
