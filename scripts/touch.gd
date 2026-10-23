extends CanvasLayer

# Virtual analog sticks for touchscreens.
# The screen is split into 4 quadrants, one per player. Touching a
# quadrant makes that player join, dragging works like a joystick.
# Touch pads use joystick numbers starting at FIRST_PAD so they never
# collide with real gamepads.

const FIRST_PAD = 1000
const PAD_COUNT = 4
const STICK_RADIUS = 80.0

# finger index -> pad number
var fingers = {}
var pad_start = []
var pad_pos = []
var pad_active = []

var overlay = null

func _ready():
	set_layer(100)
	for i in range(PAD_COUNT):
		pad_start.push_back(Vector2())
		pad_pos.push_back(Vector2())
		pad_active.push_back(false)

	overlay = Node2D.new()
	overlay.set_script(preload("res://scripts/touch_overlay.gd"))
	add_child(overlay)

	set_process_input(true)

func is_touch_pad(js):
	return js >= FIRST_PAD && js < FIRST_PAD + PAD_COUNT

func get_screen_size():
	return get_viewport().get_rect().size

func get_pad_at(pos):
	var size = get_screen_size()
	var pad = 0
	if pos.x >= size.width / 2:
		pad += 1
	if pos.y < size.height / 2:
		pad += 2
	# 0 = lower left, 1 = lower right, 2 = upper left, 3 = upper right
	return pad

func _input(ev):
	if ev.type == InputEvent.SCREEN_TOUCH:
		if ev.pressed:
			var pad = get_pad_at(ev.pos)
			if !pad_active[pad]:
				fingers[ev.index] = pad
				pad_active[pad] = true
				pad_start[pad] = ev.pos
				pad_pos[pad] = ev.pos
		elif fingers.has(ev.index):
			var pad = fingers[ev.index]
			pad_active[pad] = false
			fingers.erase(ev.index)
		overlay.update()
	elif ev.type == InputEvent.SCREEN_DRAG:
		if fingers.has(ev.index):
			pad_pos[fingers[ev.index]] = ev.pos
			overlay.update()

func is_pad_pressed(pad):
	return pad_active[pad]

# Drop-in replacement for Input.get_joy_axis that also knows touch pads.
func get_joy_axis(js, axis):
	if !is_touch_pad(js):
		return Input.get_joy_axis(js, axis)

	var pad = js - FIRST_PAD
	if !pad_active[pad]:
		return 0.0

	var offset = pad_pos[pad] - pad_start[pad]
	if axis == 0:
		return clamp(offset.x / STICK_RADIUS, -1.0, 1.0)
	elif axis == 1:
		return clamp(offset.y / STICK_RADIUS, -1.0, 1.0)
	return 0.0
