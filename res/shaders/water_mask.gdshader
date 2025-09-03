shader_type spatial;
render_mode depth_draw_always, unshaded, cull_back;

void fragment() {
    // Don’t output color, just depth
    ALBEDO = vec3(0.0);
    ALPHA = 0.0;
}
