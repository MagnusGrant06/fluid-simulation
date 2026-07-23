shader_type spatial;
render_mode unshaded, depth_test_disabled;

uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

uniform float visibility = 0.05;
uniform vec3 sun_direction;
uniform float god_ray_strength = 0.4;

const int NUM_SAMPLES = 60;
const float density = 0.6;
const float decay = 0.99;
const float exposure = 0.1;
const float weight = 0.3;

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

//convert directional light direction to 2d screen space position
vec2 calculate_2d_light_pos(mat4 view, mat4 proj, vec3 cam_pos, vec3 light_dir){
	vec3 far_point = cam_pos - light_dir * 10000.0; //get point super far along direction of sun
	vec4 clip_pos = proj * view * vec4(far_point, 1.0);
	vec2 screen_pos = (clip_pos.xy / clip_pos.w) * 0.5 + 0.5;
	return screen_pos;
}

//compute light scattering effect from sun onto screen whilst underwater 
vec3 compute_god_ray(vec2 tex_coord, vec2 light_pos){
	//vector from light source to pixel in screen space
	vec2 delta_tex_coord = (tex_coord - light_pos);
	
	delta_tex_coord *= 1.0f / float(NUM_SAMPLES) * density;
	//get initial color sample from screen buffer
	vec3 color = texture(screen_texture, tex_coord).rgb;
	
	float illumination_decay = 1.0f;
	
	//sum color over NUM_SAMPLES iterations
	for(int i = 0; i < NUM_SAMPLES; i++){
		//step sample towards sun
		tex_coord -= delta_tex_coord;
		//samples and apply decay
		vec3 sample  = texture(screen_texture, tex_coord).rgb;
		sample *= illumination_decay * weight;
		
		//accumulate color and decay of ray
		color += sample;
		illumination_decay *= decay;
	}
	
	return color * exposure;
}


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	//use beer lampbert with the depth of each pixel to get light absorption
	float depth = calculate_pixel_depth(SCREEN_UV, VERTEX, INV_PROJECTION_MATRIX);
	float transmittance = exp(-depth * visibility);
	
	//sample screen buffer to allow color to pass through filter
	vec3 ocean_color = vec3(0.2588, 0.4537, 0.9608);
	float depth_factor = clamp(1.0 - transmittance,0.0,1.0);
	vec3 screen_color = texture(screen_texture, SCREEN_UV).rgb;
	
	vec3 tint_color =  mix(screen_color, ocean_color, depth_factor);
	
	//calculate god rays in relation to sun position and camera position then mix colors
	vec2 light_pos = calculate_2d_light_pos(VIEW_MATRIX, PROJECTION_MATRIX, CAMERA_POSITION_WORLD, sun_direction);
	vec3 god_ray_col = compute_god_ray(SCREEN_UV, light_pos);
	vec3 final = tint_color + god_ray_col * god_ray_strength;
	
	ALBEDO = final;
	ALPHA = 0.85;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
