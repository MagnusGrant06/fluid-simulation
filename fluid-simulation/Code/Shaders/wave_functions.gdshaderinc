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

//calculate set waves at given params
vec3 calculate_summed_waves_offset(vec3 vertex, float wave_amplitude, float wave_steepness, float wave_length, float t){
	//calculate multiple waves in different directions to create realistic waves
	vec3 d1 = calculate_offset(vertex, wave_amplitude, vec2(1,0), wave_steepness, wave_length, t);
	vec3 d2 = calculate_offset(vertex, wave_amplitude*1.5, vec2(0,1), wave_steepness*0.75, wave_length*1.5, t);
	vec3 d3 = calculate_offset(vertex, wave_amplitude*0.75, vec2(0.5,0.5), wave_steepness*1.5, wave_length*0.5, t);
	vec3 d4 = calculate_offset(vertex, wave_amplitude*0.33, vec2(-0.5, -0.5), wave_steepness*1.5, wave_length * 0.25, t);
	
	vec3 d = d1 + d2 + d3 + d4;
	return vec3(vertex.x + d.x, vertex.y + d.y, vertex.z + d.z);
}

//calculate set wave normals for use in multiple places without dissonance
vec3 calculate_summed_waves_normal(vec3 vertex, float wave_amplitude, float wave_steepness, float wave_length, float t){
	vec3 n1 = calculate_normal(vertex, wave_amplitude, vec2(1,0), wave_steepness, wave_length, t);
	vec3 n2 = calculate_normal(vertex, wave_amplitude*1.5, vec2(0,1), wave_steepness*0.75, wave_length*1.5, t);
	vec3 n3 = calculate_normal(vertex, wave_amplitude*0.75, vec2(0.5,0.5), wave_steepness*1.5, wave_length*0.5, t);
	vec3 n4 = calculate_normal(vertex, wave_amplitude*0.33, vec2(-0.5, -0.5), wave_steepness*1.5, wave_length * 0.25, t);
	vec3 n = normalize(vec3(0,1,0) + (n1 + n2 + n3 + n4));
	return n;
}

//convert 3d vector to 2d latitude/longitude for sampling textures
vec2 direction_to_equirect_uv(vec3 dir) {
    dir = normalize(dir);
    float u = atan(dir.z, dir.x) / (2.0 * PI) + 0.5;
    float v = asin(dir.y) / PI + 0.5;
    return vec2(u, v);
}