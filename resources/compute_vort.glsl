#version 450 

#define EPS 0.0001

layout(local_size_x = 1, local_size_y = 1) in;											//local group of shaders
layout(rgba32f, binding = 0) uniform image2D img_input;									//input image
layout(rgba32f, binding = 1) uniform image2D img_output;									//output image

vec4 getPixel(ivec2 pixel_coords) {		
	vec4 col=imageLoad(img_input, pixel_coords);
	vec4 va;
	
	va.xyz = normalize(col.rgb - vec3(0.5,0.5,0.5)) * col.a;
	va.a = col.a;
	if(col.r < EPS && col.g < EPS && col.b < EPS) va.xyz = vec3(0);
	return va;
}

float curl(ivec2 coords) {
	vec4 u = getPixel(coords+ivec2(0,1));
	vec4 d = getPixel(coords+ivec2(0,-1));
	vec4 l = getPixel(coords+ivec2(-1,0));
	vec4 r = getPixel(coords+ivec2(1,0));
	return u.x-d.x + l.y-r.y;
}

void main() 
	{
	ivec2 pixel_coords = ivec2(gl_GlobalInvocationID.xy);	
	vec4 col= imageLoad(img_input, pixel_coords);
	if(col.r < EPS && col.g < EPS && col.b < EPS) return;
	vec4 va = getPixel(pixel_coords);

	//Vorticity
	if (pixel_coords.x>0 && pixel_coords.x<1200-1
		&& pixel_coords.y>0 && pixel_coords.y<720-1) {
		float vort = 10.0, dt = 0.011;
		vec2 dir;
		float dird = abs(curl(pixel_coords+ivec2(0,-1)));
		float diru = abs(curl(pixel_coords+ivec2(0,1)));
		float dirr = abs(curl(pixel_coords+ivec2(1,0)));
		float dirl = abs(curl(pixel_coords+ivec2(-1,0)));
		dir.x = dird-diru;
		dir.y = dirr-dirl;
		dir = vort/(length(dir)+1e-5f)*dir;
		va.xy = va.xy+dt*curl(pixel_coords)*dir;
	}

	col.rgb = normalize(va.xyz)/2. + vec3(0.5,0.5,0.5);
	col.a = va.a;

	imageStore(img_output, pixel_coords, col);
	}