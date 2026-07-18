shader_type spatial;
#include "wave_functions.gdshaderinc"

uniform sampler2D caustic_texture  : source_color, repeat_enable, filter_linear;

uniform float wave_length = 7.5;
uniform float wave_amplitude = 0.5;
uniform float wave_steepness = 0.75;

uniform float time = 0.0;
uniform vec3 light_direction;

const float air_index = 1.0;
const float water_index = 1.33333;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX,1.0)).xyz;
	vec3 normal = calculate_summed_waves_normal(world_pos, wave_amplitude, wave_steepness, wave_length, time);
	vec3 ray_dir = refract(light_direction, normal, air_index / water_index);
	vec3 ray_pos = calculate_summed_waves_offset(world_pos, wave_amplitude, wave_steepness, wave_length, time);
	
	float t = (world_pos.y - ray_pos.y) / ray_dir.y;
	vec3 intersection = ray_pos + ray_dir *t;
	
	vec2 sample_pos = intersection.xz;
	vec2 uv = ((sample_pos / 10.0) + 0.5) * 2.0;
	vec4 caustic_col = texture(caustic_texture, uv);
	
	vec3 ground_color = vec3(0.76, 0.70, 0.50);
	
	ALBEDO = mix(ground_color, caustic_col.rgb, 0.5);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
