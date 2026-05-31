shader_type spatial;
render_mode unshaded, cull_front;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 10.0) = 0.03;

void vertex() {
    vec3 smooth_normal = normalize(VERTEX);

    vec4 clip_position = PROJECTION_MATRIX * (MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
    vec3 clip_normal = mat3(PROJECTION_MATRIX) * mat3(MODELVIEW_MATRIX) * smooth_normal;

    vec2 offset = normalize(clip_normal.xy);
    clip_position.xy += offset * outline_width * clip_position.w * 0.1;
    POSITION = clip_position;
}

void fragment() {
    ALBEDO = outline_color.rgb;
    ALPHA = outline_color.a;
}