shader_type spatial;
render_mode
	// Vertex or pixel shading (screen-large object can use vertex)
	vertex_lighting,
	
	// Blending and culling.
	blend_mix,
	cull_back,
	
	//unshaded,
	diffuse_lambert, 
	specular_disabled,
	
	// Additional flags just in case.
	//ambient_light_disabled,
	depth_draw_opaque;

uniform vec4 albedo : hint_color;
uniform vec4 albedo_overlay : hint_color;

uniform sampler2D major_detail_noise : hint_normal;
uniform sampler2D small_detail_noise : hint_normal;
uniform sampler2D micro_detail_noise : hint_normal;
uniform sampler2D lava_detail_noise : hint_normal;

uniform float major_detail_phase : hint_range(0, 3.14) = 1.4;
uniform float small_detail_phase : hint_range(0, 3.14) = 1.0;
uniform float micro_detail_phase : hint_range(0, 3.14) = 0.4;
uniform float lava_mask_phase : hint_range(0, 3.14) = 1.4;
uniform float lava_detail_phase : hint_range(0, 3.14) = 1.0;
uniform float lava_decay_distance = 1e6;

uniform float major_detail_scale : hint_range(1.0, 10.0, 1.0) = 1;
uniform float small_detail_scale : hint_range(1.0, 10.0, 1.0) = 5;
uniform float micro_detail_scale : hint_range(1.0, 50.0, 1.0) = 10;
uniform float lava_detail_scale : hint_range(1.0, 100.0, 1.0) = 20;

uniform float detail_min : hint_range(-1.0, 1.0) = 0.0;
uniform float detail_max : hint_range(0.0, 1.0) = 1.0;

uniform float lava_detail_intensity : hint_range(0, 10.0) = 1.0;
uniform float lava_noise_blend = 0.7;
uniform float lava_contrast = 3.0;
uniform float lava_flow = 0.01;

uniform float uv_shift_x = 0.0;
uniform float uv_shift_y = 0.0;

const float pi = 3.1415926535;


// Add this before your vertex shader.
// Edit "Fcoef" to adjust for desirable view distance. Lesser number means further distance limit.
uniform float Fcoef = 0.001;
varying float gl_Position_z;

void vertex() {
	
	vec4 gl_Position = MODELVIEW_MATRIX*vec4(VERTEX, 1.0);
	gl_Position_z = gl_Position.z;

	UV.x *= 0.5; UV.x += uv_shift_x;
	UV.y *= 0.5; UV.y += uv_shift_y;
}

void fragment()
{
	// Surface details major.
	vec2 p = texture(major_detail_noise, -UV * 2.0 * major_detail_scale).xy;
	vec2 p2 = texture(small_detail_noise, -UV * 2.0 * small_detail_scale).xy;
	vec2 p2_1 = texture(micro_detail_noise, -UV*micro_detail_scale).xy;
	vec2 p3 = texture(lava_detail_noise, -UV * 2.0 * lava_detail_scale).xy -TIME*lava_flow;
	
	float detail_major_lava_mask = sin(texture(major_detail_noise, p).r*pi+lava_mask_phase);
	float detail_major = clamp(sin(texture(major_detail_noise, p).r*pi+major_detail_phase), detail_min, detail_max);
	float detail_small = clamp(sin(texture(small_detail_noise, p2).r*pi+small_detail_phase), detail_min, detail_max);
	float detail_micro = clamp(sin(texture(micro_detail_noise, p2_1).r*pi+micro_detail_phase), detail_min, detail_max);
	float detail_lava = sin(texture(lava_detail_noise, p3).r*pi+lava_detail_phase);
	
	float lava = clamp(
			detail_lava
			-clamp(pow(detail_major_lava_mask, lava_noise_blend),1e-6, 1.0)*lava_contrast,
		1e-6, 0.5)*lava_detail_intensity *(1.0 - length(VERTEX)/lava_decay_distance);
	
	ALBEDO = albedo.rgb * detail_major * (detail_small * detail_micro + albedo_overlay.rgb);
	
	EMISSION = vec3(lava, 0.0, 0.0);
	ROUGHNESS = 1.0;
	DEPTH = log2(max(1e-6, 1.0 -gl_Position_z)) * Fcoef;
}
