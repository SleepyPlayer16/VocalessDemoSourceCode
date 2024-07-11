extends ColorRect
#
#var colors = [    Color.from_hsv(0, 1, 1),    Color.from_hsv(30, 1, 1),    Color.from_hsv(60, 1, 1),    Color.from_hsv(120, 1, 1),    Color.from_hsv(180, 1, 1),    Color.from_hsv(240, 1, 1),    Color.from_hsv(300, 1, 1),]
#
#var gradient = Gradient.new()
#var current_color_index = 0
#
#func _ready():
#	# Create the gradient and set it as the texture
#	gradient.set_blend_mode(Gradient.BLEND_LINEAR)
#	gradient.set_offset(0.0)
#	for i in range(colors.size()):
#		gradient.add_color(colors[i], i / float(colors.size() - 1))
#	self.set_texture(gradient)
#
#func _process(delta):
#	# Update the offset of the gradient to create a scrolling effect
#	gradient.set_offset(gradient.get_offset() + delta)
