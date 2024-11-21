class_name DrawnArea2D
extends Area2D

## DrawnArea2D
##
## A [Area2D] with the ability to draw it's [CollisionShape2D]s and [CollisionPolygon2D]s
## even when not in the editor.[br]
## It's safe to disable [member redraw_on_frame] and [member redraw_on_physics] and/or
## use [method queue_redraw] to manually redraw this node without issue.

## The [Color] to draw the shapes with. The area of the shape will be filled with this exact color,
## and the edges of the shapes will be drawn win this color, but ignoring it's alpha value,
## forcing it to [code]1.0[/code], maximum opacity.[br]
## This behaviour replicates the drawing done in editor.
@export var color := Color.BLACK

## Redraw the shapes every processed frame.
## May help fix the drawn area not properly matching the current location of the area, when set,
## though increases rendering load.[br]
## NOTE at least this or [member redraw_on_physics] must be [code]true[/code]
## for this area to be drawn.
@export var redraw_on_frame := true

## Redraw the shapes every processed physics frame.
## May help fix the drawn area not properly matching the current location of the area, when set,
## though increases rendering load.[br]
## NOTE at least this or [member redraw_on_frame] must be [code]true[/code]
## for this area to be drawn.
@export var redraw_on_physics := false

func _ready() -> void:
	if not Engine.is_editor_hint():
		queue_redraw()

func _draw():
	for child in find_children("*", "CollisionShape2D", false, false):
		RenderingServer.canvas_item_clear(child.get_canvas_item())
		child.shape.draw(child.get_canvas_item(), color)
	for child in find_children("*", "CollisionPolygon2D", false, false):
		RenderingServer.canvas_item_clear(child.get_canvas_item())
		var color_array := PackedColorArray()
		color_array.resize(child.polygon.size())
		color_array.fill(color)
		RenderingServer.canvas_item_add_polygon(child.get_canvas_item(), child.polygon, color_array)
		if color.a < 1:
			var c := Color(color, 1)
			var ca := PackedColorArray()
			ca.resize(child.polygon.size())
			ca.fill(c)
			RenderingServer.canvas_item_add_polyline(child.get_canvas_item(), child.polygon, ca)
			# Connect the start of the polyline to the end.
			RenderingServer.canvas_item_add_line(child.get_canvas_item(),
												 child.polygon[-1],
												 child.polygon[0],
												 c
												)

func _process(_delta:float):
	if not Engine.is_editor_hint():
		queue_redraw()

func _physics_process(_delta:float):
	if not Engine.is_editor_hint():
		queue_redraw()
