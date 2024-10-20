extends VBoxContainer


signal clicked(component: Component);


@onready var label: Label = $Label;
@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport;

var component: Component = null;


func _ready() -> void:
	if component == null:
		queue_free();
	
	label.text = str(component.cost);
	var tile = component.tile_scene.instantiate();
	tile.process_mode = Node.PROCESS_MODE_DISABLED;
	sub_viewport.add_child(tile);
	#texture_rect.texture = component.icon;
	#texture_rect.flip_h = component.h_flipped;


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				clicked.emit(component);
