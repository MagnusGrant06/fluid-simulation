shader_type spatial;
render_mode unshaded, depth_test_disabled;

uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

uniform float visibility = 0.05;
//use depth buffer to calculate distance from canmera to objects to add light absorption
float calculate_pixel_depth(vec2 uv, vec3 vertex, mat4 inverse_proj){
	float raw_depth = texture(depth_texture, uv).r;
	
	//convert non-linear depth buffer value to usable world space position
	vec3 ndc = vec3(uv * 2.0 - 1.0, raw_depth);
	vec4 view_pos = inverse_proj * vec4(ndc,1.0);
	view_pos.xyz /= view_pos.w;
	
	float camera_z = -vertex.z;
	float scene_depth = -view_pos.z;
	
	return max(scene_depth - camera_z, 0.0);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	float depth = calculate_pixel_depth(SCREEN_UV, VERTEX, INV_PROJECTION_MATRIX);
	float transmittance = exp(-depth * visibility);
	
	vec3 ocean_color = vec3(0.2588, 0.4537, 0.9608);
	float depth_factor = clamp(1.0 - transmittance,0.0,1.0);
	vec3 screen_color = texture(screen_texture, SCREEN_UV).rgb;
	
	ALBEDO =  mix(screen_color, ocean_color, depth_factor);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
