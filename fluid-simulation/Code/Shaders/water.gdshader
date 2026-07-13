shader_type spatial;
uniform samplerCube sky_texture;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
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

void vertex() {
	// Called for every vertex the material is visible on.
	
	//calculate multiple waves in different directions to create realistic waves
	vec3 d1 = calculate_offset(VERTEX, 0.5, vec2(1,0), 0.8, 6.0, TIME);
	vec3 d2 = calculate_offset(VERTEX, 0.8, vec2(0,1), 0.5, 10.0, TIME);
	vec3 d3 = calculate_offset(VERTEX, 0.3, vec2(0.5,0.5), 1.0, 5.0, TIME);
	
	vec3 d = d1 + d2 + d3;
	
	VERTEX = vec3(VERTEX.x + d.x, d.y, VERTEX.z + d.z);
}

void fragment() {
	// Called for every pixel the material is visible on.
	// r(th) = R(0) + (1-R0)(1-cos(th)^5
	//where r(0) = ((n1-n2)/(n1+n2))^2 where n1 is assumed to be 1 and n2 is ~= 1.33?
	float r0 = pow((air_index-water_index) / (air_index + water_index), 2);
	
	float cos_theta = clamp( dot(normalize(VIEW),normalize(NORMAL)), 0.0, 1.0);
	
	float R = r0 + (1.0 - r0) * pow( (1.0-cos_theta) ,5);
	
	vec3 refraction_color = texture(screen_texture, SCREEN_UV + vec2(0.01,0.01)).rgb;
	
	vec3 reflect_dir = reflect(-VIEW, NORMAL);
	vec3 reflection_color = texture(sky_texture, reflect_dir).rgb;
	
	vec3 final_color = mix(refraction_color, reflection_color, R);
	ALBEDO = final_color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
