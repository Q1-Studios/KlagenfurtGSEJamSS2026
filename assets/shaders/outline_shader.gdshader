shader_type spatial;
render_mode unshaded, cull_front;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_width : hint_range(0.0, 0.1, 0.001) = 0.03;

void vertex() {
    vec4 clip_pos = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
    vec3 clip_norm = mat3(PROJECTION_MATRIX) * mat3(MODELVIEW_MATRIX) * NORMAL;
    clip_pos.xy += normalize(clip_norm.xy) * outline_width * clip_pos.w * 0.1;
    POSITION = clip_pos;
}

void fragment() {
    ALBEDO = outline_color.rgb;
    ALPHA = outline_color.a;
}