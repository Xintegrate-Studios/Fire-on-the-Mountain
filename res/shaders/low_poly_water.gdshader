shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

// Water color
uniform vec4 out_color : source_color = vec4(0.0, 0.4, 1.0, 0.8);

// Wave settings
uniform float amount : hint_range(0.1, 5.0, 0.1) = 0.8;
uniform float speed : hint_range(0.1, 5.0, 0.1) = 1.0;

// Surface properties
uniform float metallic = 0.2;
uniform float specular = 0.5;
uniform float roughness = 0.1;

// Generate offset for waves
float generateOffset(float x, float z, float val1, float val2, float time) {
	float radiansX = ((mod(x + z * x * val1, amount) / amount)
		+ (time * speed) * mod(x * 0.8 + z, 1.5)) * 6.28318; // 2*PI
	float radiansZ = ((mod(val2 * (z * x + x * z), amount) / amount)
		+ (time * speed) * 2.0 * mod(x, 2.0)) * 6.28318;
	return amount * 0.5 * (sin(radiansZ) * cos(radiansX));
}

void vertex() {
	// Only displace Y for water
	float wave = generateOffset(VERTEX.x, VERTEX.z, 0.2, 0.1, TIME * 0.1);
	VERTEX.y += wave;
}

void fragment() {
	// Flat shading normal
	NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));

	METALLIC = metallic;
	SPECULAR = specular;
	ROUGHNESS = roughness;
	ALBEDO = out_color.rgb;
	ALPHA = out_color.a;
}
