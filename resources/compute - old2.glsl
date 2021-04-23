#version 450 
layout(local_size_x = 1, local_size_y = 1) in;											//local group of shaders
layout(rgba32f, binding = 0) uniform image2D img_input;									//input image
layout(rgba32f, binding = 1) uniform image2D img_output;									//output image
void main() 
	{
	ivec2 pixel_coords = ivec2(gl_GlobalInvocationID.xy);				
	vec4 l,u,r,d, ld,lu,rd,ru;//left up right down				
	vec4 col=imageLoad(img_input, pixel_coords);
	vec3 va,vl,vr,vu,vd;
	va = normalize(col.rgb - vec3(0.5,0.5,0.5)) * col.a;

	l=u=r=d=ld=lu=rd=ru=col;
	if(pixel_coords.x>0)	l=imageLoad(img_input, pixel_coords + ivec2(-1,0));
	if(pixel_coords.y>0)	d=imageLoad(img_input, pixel_coords + ivec2(0,-1));
	if(pixel_coords.x<1200-1)	r=imageLoad(img_input, pixel_coords + ivec2(1,0));
	if(pixel_coords.y<720-1)	u=imageLoad(img_input, pixel_coords + ivec2(0,1));

	vr = normalize(r.rgb - vec3(0.5,0.5,0.5)) * r.a;
	vl = normalize(l.rgb - vec3(0.5,0.5,0.5)) * l.a;
	vu = normalize(u.rgb - vec3(0.5,0.5,0.5)) * u.a;
	vd = normalize(d.rgb - vec3(0.5,0.5,0.5)) * d.a;

	col.rgb = normalize(col.rgb - vec3(0.5,0.5,0.5));
	
	col.a = max(1,length(va));
//	col.a =1;
	float a = col.a;
	float p = 0.005;
	int arrowfound = 0;

	if (abs(vl.y) < vl.x) {
		a += p*l.a;// *vl.r/l.a;
		arrowfound = 1;
	}
//	else if (l.a < col.a)
//		a -= p*col.a;

	if (abs(vd.x) < vd.y) {
		a += p*d.a;// *vd.g/d.a;
		arrowfound = 1;
	}
//	else if (d.a < col.a)
//		a -= p*col.a;
	
	if (-abs(vr.y) > vr.x) {
		a += p*r.a;// *abs(vr.r)/r.a;
		arrowfound = 1;
	}
//	else if (r.a < col.a)
//		a -= p*col.a;
	
	if (-abs(vu.x) > vu.y) {
		a += p*u.a;// *abs(vu.g)/u.a;
		arrowfound = 1;
	}
//	else if (u.a < col.a)
//		a -= p*col.a;

	if (arrowfound == 0)
		if (l.a < col.a || r.a < col.a || u.a < col.a || d.a < col.a)
			a -= p*col.a;

	//if(vl.x>0) va.x=1;
	col.rgb = normalize(va)/2. + vec3(0.5,0.5,0.5);

	col.rgb = va/2. + vec3(0.5,0.5,0.5);
	col.a = a;

	imageStore(img_output, pixel_coords, col);
	}