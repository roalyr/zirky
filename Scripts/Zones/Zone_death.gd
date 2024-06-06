extends Area
class_name DeathZone, "res://Assets_new/UI_images/SVG/icons/death_zone.svg"


func _ready():
	# Disable "Monitorable" for the sake of performance.
	self.monitorable = false
	self.monitoring = true
