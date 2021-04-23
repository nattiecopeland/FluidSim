#version 450 
layout(local_size_x = 1, local_size_y = 1) in;											//local group of shaders
layout(rgba32f, binding = 0) uniform image2D img_input;									//input image
layout(rgba32f, binding = 1) uniform image2D img_output;									//output image
layout(rgba32f, binding = 2) uniform image2D img_temp_output;

/*
vec3 bilinearInterp(vec2 coords) {
	vec2 weight = fract(coords);
	ivec2 coordsfloor = ivec2(coords);

	vec4 bot = mix(imageLoad(img_input, coordsfloor),
					imageLoad(img_input, coordsfloor+ivec2(1,0)),
					weight.x);
	vec4 top = mix(imageLoad(img_input, coordsfloor+ivec2(0,1)),
					imageLoad(img_input, coordsfloor+ivec2(1,1)),
					weight.x);

	vec4 newpos = mix(bot, top, weight.y);
	return normalize(newpos.rgb - vec3(0.5,0.5,0.5)) * newpos.a;
}

void main() 
	{
	ivec2 pixel_coords = ivec2(gl_GlobalInvocationID.xy);				
	vec4 l,u,r,d, ld,lu,rd,ru;//left up right down				
	vec4 col=imageLoad(img_input, pixel_coords);
	vec3 va,vl,vr,vu,vd;

	l=u=r=d=ld=lu=rd=ru=col;
	if(pixel_coords.x>0)	l=imageLoad(img_input, pixel_coords + ivec2(-1,0));
	if(pixel_coords.y>0)	d=imageLoad(img_input, pixel_coords + ivec2(0,-1));
	if(pixel_coords.x<1200-1)	r=imageLoad(img_input, pixel_coords + ivec2(1,0));
	if(pixel_coords.y<720-1)	u=imageLoad(img_input, pixel_coords + ivec2(0,1));

	va = normalize(col.rgb - vec3(0.5,0.5,0.5)) * col.a;
	vr = normalize(r.rgb - vec3(0.5,0.5,0.5)) * r.a;
	vl = normalize(l.rgb - vec3(0.5,0.5,0.5)) * l.a;
	vu = normalize(u.rgb - vec3(0.5,0.5,0.5)) * u.a;
	vd = normalize(d.rgb - vec3(0.5,0.5,0.5)) * d.a;

	if(pixel_coords.x>0 && pixel_coords.y>0 &&
		pixel_coords.x<1200-1 && pixel_coords.y<720-1) {
		float p = 1;
		vec2 pos = pixel_coords - p * va.xy;
		va = bilinearInterp(pos);
	}

	float alpha = 2.;
	float beta = 4. + alpha;
	va = (vl+vr+vd+vu+alpha*va)/beta;

	col.rgb = normalize(va)/2. + vec3(0.5,0.5,0.5);
	col.a = length(va);

	imageStore(img_output, pixel_coords, col);

	if (col.a >= 0.996)
		col.rgb = vec3(1,0.5,0.5);
	else if (col.a <= 1)
		col.rgb = vec3(0.5,0.5,1);

	imageStore(img_temp_output, pixel_coords, col);
	}
*/

vec4 bilinearInterp(vec2 coords) {
	vec2 weight = fract(coords);
	ivec2 coordsfloor = ivec2(coords);

	vec4 bot = mix(imageLoad(img_input, coordsfloor),
					imageLoad(img_input, coordsfloor+ivec2(1,0)),
					weight.x);
	vec4 top = mix(imageLoad(img_input, coordsfloor+ivec2(0,1)),
					imageLoad(img_input, coordsfloor+ivec2(1,1)),
					weight.x);

	vec4 newpos = mix(bot, top, weight.y);
	newpos.xyz = normalize(newpos.rgb - vec3(0.5,0.5,0.5)) * newpos.a;
	return newpos;
}

void main() 
	{
	ivec2 pixel_coords = ivec2(gl_GlobalInvocationID.xy);				
	vec4 l,u,r,d, ld,lu,rd,ru;//left up right down				
	vec4 col=imageLoad(img_input, pixel_coords);
	vec4 va,vl,vr,vu,vd;

	l=u=r=d=ld=lu=rd=ru=col;
	if(pixel_coords.x>0)	l=imageLoad(img_input, pixel_coords + ivec2(-1,0));
	if(pixel_coords.y>0)	d=imageLoad(img_input, pixel_coords + ivec2(0,-1));
	if(pixel_coords.x<1200-1)	r=imageLoad(img_input, pixel_coords + ivec2(1,0));
	if(pixel_coords.y<720-1)	u=imageLoad(img_input, pixel_coords + ivec2(0,1));

	va = vec4(normalize(col.rgb - vec3(0.5,0.5,0.5)) * col.a, col.a);
	vr = vec4(normalize(r.rgb - vec3(0.5,0.5,0.5)) * r.a, r.a);
	vl = vec4(normalize(l.rgb - vec3(0.5,0.5,0.5)) * l.a, l.a);
	vu = vec4(normalize(u.rgb - vec3(0.5,0.5,0.5)) * u.a, u.a);
	vd = vec4(normalize(d.rgb - vec3(0.5,0.5,0.5)) * d.a, d.a);

	if(pixel_coords.x>0 && pixel_coords.y>0 &&
		pixel_coords.x<1200-1 && pixel_coords.y<720-1) {
		float p = 1;
		vec2 pos = pixel_coords - p * va.xy;
		va = bilinearInterp(pos);
	}

	float alpha = 2.;
	float beta = 4. + alpha;
	va = (vl+vr+vd+vu+alpha*va)/beta;

	col.rgb = normalize(va.xyz)/2. + vec3(0.5,0.5,0.5);
//	col.a = length(va.xyz);
	col.a = va.a;

	imageStore(img_output, pixel_coords, col);
	}