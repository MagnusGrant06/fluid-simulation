shader_type spatial;

uniform samplerCube sky_texture;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

uniform float wave_length = 7.5;
uniform float wave_amplitude = 0.5;
uniform float wave_steepness = 0.75;

const float air_index = 1.0f;
const float water_index = 1.33f;

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

void vertex() {
	// Called for every vertex the material is visible on.
	
	//calculate multiple waves in different directions to create realistic waves
	vec3 d1 = calculate_offset(VERTEX, wave_amplitude, vec2(1,0), wave_steepness, wave_length, TIME);
	vec3 d2 = calculate_offset(VERTEX, wave_amplitude*1.5, vec2(0,1), wave_steepness*0.75, wave_length*1.5, TIME);
	vec3 d3 = calculate_offset(VERTEX, wave_amplitude*0.75, vec2(0.5,0.5), wave_steepness*1.5, wave_length*0.5, TIME);
	//vec3 d4 = calculate_offset(VERTEX, wave_amplitude*0.25, vec2(-0.7,0.3), wave_steepness*2.0, wave_length*0.68, TIME);
	//vec3 d5 = calculate_offset(VERTEX, wave_amplitude*1.24, vec2(0.6,0.9), wave_steepness*1.78, wave_length*1.34, TIME);
	
	vec3 n1 = calculate_normal(VERTEX, wave_amplitude, vec2(1,0), wave_steepness, wave_length, TIME);
	vec3 n2 = calculate_normal(VERTEX, wave_amplitude*1.5, vec2(0,1), wave_steepness*0.75, wave_length*1.5, TIME);
	vec3 n3 = calculate_normal(VERTEX, wave_amplitude*0.75, vec2(0.5,0.5), wave_steepness*1.5, wave_length*0.5, TIME);
	//vec3 n4 = calculate_normal(VERTEX, wave_amplitude*0.25, vec2(-0.7,0.3), wave_steepness*2.0, wave_length*0.68, TIME);
	//vec3 n5 = calculate_normal(VERTEX, wave_amplitude*1.24, vec2(0.6,0.9), wave_steepness*1.78, wave_length*1.34, TIME);
	
	vec3 d = d1 + d2 + d3;
	vec3 n = normalize(vec3(0,1,0) + (n1 + n2 + n3));
	
	VERTEX = vec3(VERTEX.x + d.x, d.y, VERTEX.z + d.z);
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
	vec3 reflection_color = texture(sky_texture, reflect_dir).rgb;
	
	vec3 final_color = mix(refraction_color, reflection_color, R);
	//ALBEDO = vec3(0.5) + 0.5 * NORMAL;
	ALBEDO = final_color;
	SPECULAR = 0.5;
	ROUGHNESS = 0.05;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
