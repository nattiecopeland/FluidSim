#version 450 
layout(local_size_x = 1, local_size_y = 1) in;											//local group of shaders
layout(rgba32f, binding = 0) uniform image2D img_input;									//input image
layout(rgba32f, binding = 1) uniform image2D img_output;									//output image
void main() 
	{
	ivec2 pixel_coords = ivec2(gl_GlobalInvocationID.xy);				
	vec4 l,u,r,d;//left up right down				
	vec4 col=imageLoad(img_input, pixel_coords);
	vec3 va,vl,vr,vu,vd;
	va = normalize(col.rgb - vec3(0.5,0.5,0.5)) * col.a;

	l=u=r=d=col;
	if(pixel_coords.x>0)	l=imageLoad(img_input, pixel_coords + ivec2(-1,0));
	if(pixel_coords.y>0)	d=imageLoad(img_input, pixel_coords + ivec2(0,-1));
	if(pixel_coords.x<1200-1)	r=imageLoad(img_input, pixel_coords + ivec2(1,0));
	if(pixel_coords.y<720-1)	u=imageLoad(img_input, pixel_coords + ivec2(0,1));

	vr = normalize(r.rgb - vec3(0.5,0.5,0.5)) * r.a;
	vl = normalize(l.rgb - vec3(0.5,0.5,0.5)) * l.a;
	vu = normalize(u.rgb - vec3(0.5,0.5,0.5)) * u.a;
	vd = normalize(d.rgb - vec3(0.5,0.5,0.5)) * d.a;

	float distrib = 0.5;
	vec3 left = vec3(-1, 0, 0);
	vec3 right = vec3(1, 0, 0);
	vec3 up = vec3(0, 1, 0);
	vec3 down = vec3(0, -1, 0);

	l.rgb = normalize(l.rgb - vec3(0.5,0.5,0.5));
	r.rgb = normalize(r.rgb - vec3(0.5,0.5,0.5));
	u.rgb = normalize(u.rgb - vec3(0.5,0.5,0.5));
	d.rgb = normalize(d.rgb - vec3(0.5,0.5,0.5));
	col.rgb = normalize(col.rgb - vec3(0.5,0.5,0.5));
//	float dotL = dot(right, l.rgb);
//	float dotR = dot(left, r.rgb);  
//	float dotU = dot(down, u.rgb);
//	float dotD = dot(up, d.rgb);
//
//	l.a += col.a * dotL * distrib * length(col.rgb);
//	l.rgb += col.rgb * dotL * distrib * length(col.rgb);
//
//	l.a = l.a * dotL * distrib * length(col.rgb);
//	r.a = r.a * dotR * distrib * length(col.rgb);
//	u.a = u.a * dotU * distrib * length(col.rgb);
//	d.a = d.a * dotD * distrib * length(col.rgb);
//
	// dot(col, l) = |col||l|cos(theta)
/*	vl.rgb = vl.rgb * dotL * length(right);
	vr.rgb = vr.rgb * dotR * length(left);
	vu.rgb = vu.rgb * dotU * length(down);
	vd.rgb = vd.rgb * dotD * length(up);
	
//	col.a = col.a*(1 - distrib) + (vl.a + vr.a + vu.a + vd.a)/4*distrib;
	col.rgb = col.rgb*(1 - distrib) + (vl.rgb + vd.rgb)*distrib;
	col.rgb = col.rgb/2.0 + vec3(0.5,0.5,0.5);*/

	
	col.a = max(1,length(va));
	col.a =1;
	va = vr+vl+vd+vu;

	
	//if(vl.x>0) va.x=1;
	col.rgb = normalize(va)/2. + vec3(0.5,0.5,0.5);



	imageStore(img_output, pixel_coords, col);
	}