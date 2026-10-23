extends Node2D

# Draws the virtual sticks of the touch autoload.

const color_base = Color(1, 1, 1, 0.15)
const color_knob = Color(1, 1, 1, 0.4)

func _draw():
	var touch = get_parent()
	for pad in range(touch.PAD_COUNT):
		if touch.pad_active[pad]:
			var start = touch.pad_start[pad]
			var offset = touch.pad_pos[pad] - start
			if offset.length() > touch.STICK_RADIUS:
				offset = offset.normalized() * touch.STICK_RADIUS
			draw_circle(start, touch.STICK_RADIUS, color_base)
			draw_circle(start + offset, touch.STICK_RADIUS / 2, color_knob)
