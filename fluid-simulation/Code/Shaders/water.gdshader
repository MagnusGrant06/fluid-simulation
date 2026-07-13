shader_type spatial;
uniform samplerCube sky_texture;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
const float air_index = 1.0f;
const float water_index = 1.33f;

void vertex() {
	// Called for every vertex the material is visible on.
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
