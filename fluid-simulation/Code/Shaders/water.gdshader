
shader_type spatial;

uniform sampler2D sky_texture;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;

uniform float wave_length = 7.5;
uniform float wave_amplitude = 0.5;
uniform float wave_steepness = 0.75;
uniform float visibility = 0.25;

uniform float time = 0.0;

const float air_index = 1.0f;
const float water_index = 1.33f;

//use depth buffer to calculate distance from surface to objects to add light absorption
float calculate_pixel_depth(vec2 uv, vec3 vertex, mat4 inverse_proj){
	float raw_depth = texture(depth_texture, uv).r;
	
	//convert non-linear depth buffer value to usable world space position
	vec3 ndc = vec3(uv * 2.0 - 1.0, raw_depth);
	vec4 view_pos = inverse_proj * vec4(ndc,1.0);
	view_pos.xyz /= view_pos.w;
	
	float water_surface = -vertex.z;
	float scene_depth = -view_pos.z;
	
	return max(scene_depth - water_surface, 0.0);
}
//calculate specific point of this vertex on a wave
float calculate_phase(vec3 vertex, float wavelength, vec2 direction, float t){
	float k = (2.0 * PI) / wavelength;
	float angular_freq = sqrt(0.3 * k);
	float phase = (k * (direction.x * vertex.x + direction.y * vertex.z)) - (angular_freq * t);
	
	return phase;
}

//calculate actual offset of point from wave to real vertex position
vec3 calculate_offset(vec3 vertex, float amplitude, vec2 direction, float steepness, float wavelength, float t){
	
	float phase = calculate_phase(vertex, wavelength, direction, t);
	float dx = (steepness * amplitude * direction.x * cos(phase));
	float dy = amplitude * sin(phase);
	float dz = (steepness * amplitude * direction.y * cos(phase));
	
	return vec3(dx,dy,dz);
}

//calculate normal of current vertex on wave using approximation
vec3 calculate_normal(vec3 vertex, float amplitude, vec2 direction, float steepness, float wavelength, float t){
	float wave_number = 2.0 * PI / wavelength;
	float phase = calculate_phase(vertex, wavelength, direction, t);
	float dx = -direction.x * wave_number * amplitude * cos(phase);
	float dy = 1.0 - steepness * wave_number * amplitude * sin(phase);
	float dz = -direction.y * wave_number * amplitude * cos(phase);
	
	return vec3(dx, dy, dz);
}

vec2 direction_to_equirect_uv(vec3 dir) {
    dir = normalize(dir);
    float u = atan(dir.z, dir.x) / (2.0 * PI) + 0.5;
    float v = asin(dir.y) / PI + 0.5;
    return vec2(u, v);
}

void vertex() {
	// Called for every vertex the material is visible on.
	
	//calculate multiple waves in different directions to create realistic waves
	vec3 d1 = calculate_offset(VERTEX, wave_amplitude, vec2(1,0), wave_steepness, wave_length, time);
	vec3 d2 = calculate_offset(VERTEX, wave_amplitude*1.5, vec2(0,1), wave_steepness*0.75, wave_length*1.5, time);
	vec3 d3 = calculate_offset(VERTEX, wave_amplitude*0.75, vec2(0.5,0.5), wave_steepness*1.5, wave_length*0.5, time);
	
	vec3 n1 = calculate_normal(VERTEX, wave_amplitude, vec2(1,0), wave_steepness, wave_length, time);
	vec3 n2 = calculate_normal(VERTEX, wave_amplitude*1.5, vec2(0,1), wave_steepness*0.75, wave_length*1.5, time);
	vec3 n3 = calculate_normal(VERTEX, wave_amplitude*0.75, vec2(0.5,0.5), wave_steepness*1.5, wave_length*0.5, time);
	
	vec3 d = d1 + d2 + d3;
	vec3 n = normalize(vec3(0,1,0) + (n1 + n2 + n3));
	
	VERTEX = vec3(VERTEX.x + d.x, VERTEX.y + d.y, VERTEX.z + d.z);
	NORMAL = n;

}

void fragment() {
	// Called for every pixel the material is visible on.
	// r(th) = R(0) + (1-R0)(1-cos(th)^5
	//where r(0) = ((n1-n2)/(n1+n2))^2 where n1 is assumed to be 1 and n2 is ~= 1.33?
	
	//use schlicks approximation to estimate reflectiveness of water depending on view angle
	float r0 = pow((air_index-water_index) / (air_index + water_index), 2);
	
	float cos_theta = clamp( dot(normalize(VIEW),normalize(NORMAL)), 0.0, 1.0);
	
	float R = r0 + (1.0 - r0) * pow( (1.0-cos_theta) ,5);
	
	//sample refraction from sorrounding scene
	vec3 refraction_color = texture(screen_texture, SCREEN_UV - NORMAL.xy * 0.03).rgb;
	
	//sample reflection from skybox
	vec3 reflect_dir = reflect(-VIEW, NORMAL);
	vec2 uv = direction_to_equirect_uv(reflect_dir);
	vec3 reflection_color = texture(sky_texture, uv).rgb;
	
	//approximate light falloff using Beer-Lambert law
	float water_distance = calculate_pixel_depth(SCREEN_UV - NORMAL.xy * 0.03, VERTEX, INV_PROJECTION_MATRIX);
	float transmittance = exp(-water_distance * visibility);
	//mix refraction and reflection parts with a bit of flat blue color for more believable color
	vec3 schlick_color = mix(refraction_color, reflection_color, R);
	vec3 final_color = mix(schlick_color,vec3(0.6, 0.85, 1.5), clamp(1.0 - transmittance,0.0,1.0));
	
	ALBEDO = final_color / 2.0;
	SPECULAR = 0.5;
	ROUGHNESS = 0.05;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
