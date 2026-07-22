shader_type spatial;
render_mode cull_front;
#include "wave_functions.gdshaderinc"

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

void vertex() {
	// Called for every vertex the material is visible on.
	vec3 offset = calculate_summed_waves_offset(VERTEX, wave_amplitude, wave_steepness, wave_length, time);
	vec3 normal = calculate_summed_waves_normal(VERTEX, wave_amplitude, wave_steepness, wave_length, time);
	VERTEX = offset;
	NORMAL = normal;

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
