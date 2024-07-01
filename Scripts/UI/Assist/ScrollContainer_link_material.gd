extends ScrollContainer

var pad_material = load("res://Assets_new/Themes/Default/Elements/Panel/Default_panel_mat_shader.tres")

func _ready():
	pass
	self.get_v_scrollbar().set_material(pad_material)
	self.get_h_scrollbar().set_material(pad_material)
