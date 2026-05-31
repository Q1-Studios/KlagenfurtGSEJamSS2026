shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_disabled, unshaded;

uniform sampler2D paint_texture : source_color, hint_default_transparent;
uniform vec2 world_size = vec2(440.0, 300.0);
uniform vec2 world_center = vec2(0.0, -40.573303);

void fragment() {
	vec4 world_pos = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
	vec2 paint_uv = vec2(
		(world_pos.x - world_center.x + world_size.x * 0.5) / world_size.x,
		(world_pos.z - world_center.y + world_size.y * 0.5) / world_size.y
	);
	vec4 paint_col = texture(paint_texture, paint_uv);
	ALBEDO = paint_col.rgb;
	ALPHA = paint_col.a;
	if (paint_col.a < 0.01) discard;
}
