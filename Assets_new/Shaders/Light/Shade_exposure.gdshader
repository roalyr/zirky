shader_type spatial;
render_mode
	// Vertex or pixel shading (screen-large object can use vertex)
	vertex_lighting,

	// Blending and culling.
	blend_sub,
	cull_front,

	unshaded,
	//diffuse_lambert,
	specular_disabled,

	// Additional flags just in case.
	ambient_light_disabled,
	depth_draw_opaque;

uniform vec4 albedo : hint_color;
uniform float rim_strength = 0.1;
uniform float rim_exponent = 5.0;

uniform float distance_fade = 1e11;
uniform float distance_fade_power = 1.0;
uniform float distance_factor  = 0.5;


uniform float alpha_clip :  hint_range(0.0, 1.0, 5e-4) = 1.0;


// Edit "Fcoef" to adjust for desirable view distance. Lesser number means further distance limit.
const float Fcoef = 0.001;
varying float gl_Position_z;



void vertex() {
	vec4 gl_Position = MODELVIEW_MATRIX*vec4(VERTEX, 1.0);
	gl_Position_z = gl_Position.z;
	
		// Model absolute scale.
	float abs_scale = length(vec3(WORLD_MATRIX[0][0],WORLD_MATRIX[1][1],WORLD_MATRIX[2][2]));

	// Transform the vertex position to view space
	vec4 vertex_view_space = INV_CAMERA_MATRIX * WORLD_MATRIX * vec4(VERTEX, 1.0);

	// Calculate the distance from the vertex to the camera relative to object size
	float dist = length(vertex_view_space.xyz)/abs_scale;
	
	VERTEX *= pow(dist , distance_factor);

}


void fragment()
{
	float dt = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	float rim = clamp(pow(dt, rim_exponent)*rim_strength, 1e-6, alpha_clip);
	ALBEDO = albedo.rgb*COLOR.rgb;
	ALBEDO *= rim;
	ALBEDO *= pow(1.0 - clamp(smoothstep(0.0, distance_fade, length(VERTEX)), 1e-6, 1.0), distance_fade_power);
	DEPTH = log2(max(1e-6, 1.0 -gl_Position_z)) * Fcoef;
}