extends Position3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	self.global_transform.origin = Paths.camera.global_transform.origin

