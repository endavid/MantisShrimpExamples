// #genuary28 Skeuomorphism
// Ref. https://www.shadertoy.com/view/tdS3DG

float sdTorus(float3 p, float2 t)
{
  float2 q = float2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

float sdRoundedCylinder(float3 p, float ra, float rb, float h)
{
  float2 d = float2(length(p.xz)-2.0*ra+rb, abs(p.y) - h);
  return min(max(d.x,d.y),0.0) + length(max(d,0.0)) - rb;
}


float2 map(float3 p, float time)
{
    // ellipsoid
    float3 pos1 = float3(0,0.025,0);
    float d1 = sdTorus(p-pos1, float2(0.2,0.025));
    float d2 = sdRoundedCylinder(p, 0.09, 0.05, 0.1*pow(sin(time),4)+0.02);
    // plane
    float dg = p.y;
    if (d1 < d2) {
        return (d1<dg) ? float2(d1,2.0) : float2(dg,1.0);
    }
    return (d2<dg) ? float2(d2,3.0) : float2(dg,1.0);    
}

constant int MAX_MARCHING_STEPS = 256;
constant float MIN_DIST = 0.0;
constant float MAX_DIST = 100.0;
constant float EPSILON = 0.001;

// https://iquilezles.org/articles/nvscene2008/
float2 castRay(float3 ro, float3 rd, float time)
{
    float m = 0.0;
    float t = 0.0;
    const float tmax = 20.0;
    for(int i=0; i<MAX_MARCHING_STEPS && t<tmax; i++)
    {
	    float2 h = map(ro+rd*t, time);
        if(h.x<EPSILON) break;
        m = h.y;
        t += h.x;
    }

    return (t<tmax) ? float2(t,m) : float2(0.0);
}

// https://iquilezles.org/articles/nvscene2008/
float calcAO(float3 pos, float3 nor, float time)
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/4.0;
        float3 aopos =  nor * hr + pos;
        float dd = map(aopos, time).x;
        occ += (hr-dd)*sca;
        sca *= 0.95;
    }
    return saturate(1.0 - 2.0*occ);    
}

// https://iquilezles.org/articles/rmshadows/
float calcSoftshadow(float3 ro, float3 rd, float time)
{
	float res = 1.0;
    float t = 0.01;
    for( int i=0; i<256; i++ )
    {
		float h = map(ro + rd*t, time).x;
        res = min( res, smoothstep(0.0,1.0,8.0*h/t ));
        t += clamp( h, 0.005, 0.02 );
        if( res<0.001 || t>5.0 ) break;
    }
    return clamp( res, 0.0, 1.0 );
}

// https://iquilezles.org/articles/normalsSDF/
float3 calcNormal(float3 pos, float time)
{
    float2 e = float2(1.0,-1.0)*0.5773*0.0005;
    return normalize( e.xyy*map( pos + e.xyy, time ).x + 
					  e.yyx*map( pos + e.yyx, time ).x + 
					  e.yxy*map( pos + e.yxy, time ).x + 
					  e.xxx*map( pos + e.xxx, time ).x );
}

// https://iquilezles.org/articles/checkerfiltering
float checkersGradBox(float2 p)
{
    // filter kernel
    float2 w = fwidth(p) + 0.001;
    // analytical integral (box filter)
    float2 i = 2.0*(abs(fract((p-0.5*w)*0.5)-0.5)-abs(fract((p+0.5*w)*0.5)-0.5))/w;
    // xor pattern
    return 0.5 - 0.5*i.x*i.y;
}

struct Material {
    float3 normal;
    float3 color;
    float occ;
};

Material getMaterial(float index, float3 pos, float time)
{
    float3 nor = float3(0,1,0);
    float3 col = float3(0.05);
    float occ = 1.0;
    if (index < 1.5)
    {
        col *= 0.7+0.3*checkersGradBox(pos.xz*2.0);
    }
    else
    {
        nor = calcNormal(pos, time);
        occ = 0.5+0.5*nor.y;
        col = index < 2.5 ? float3(0.15) : float3(0.1,0.01,0.01);
    }
    return Material {nor, col, occ};
}


float3 render(float3 ro, float3 rd, float time)
{ 
    float3 col = float3(0.0);
    
    float2  res = castRay(ro, rd, time);

    if( res.y>0.5 )
    {
        float t   = res.x;
        float3  pos = ro + t*rd;

        Material mat = getMaterial(res.y, pos, time);
        col = mat.color;
        float3 nor = mat.normal;
        float3 occ = mat.occ;

        // lighting
        occ *= calcAO(pos, nor, time);

        float3  lig = normalize( float3(-0.5, 1, 0.8) );
        float3  hal = normalize( lig-rd );
        float amb = clamp( 0.5+0.5*nor.y, 0.0, 1.0 );
        float dif = clamp( dot( nor, lig ), 0.0, 1.0 );

        float sha = calcSoftshadow( pos, lig, time );
        sha = sha*sha;

        float spe = pow( clamp( dot( nor, hal ), 0.0, 1.0 ),32.0)*
                    dif * sha *
                    (0.04 + 0.96*pow( clamp(1.0+dot(hal,rd),0.0,1.0), 5.0 ));
        col *= 5.0;
        col *= float3(0.2,0.3,0.4)*amb*occ + 1.6*float3(1.0,0.9,0.75)*dif*sha;
        col += float3(2.8,2.2,1.8)*spe*3.0;         
    }
    else
    {
        // fake sky
        float y = 0.5*dot(float3(0,1,0), rd)+0.5;
        col = float3(0.4,0.6,0.7) * y;
    }
    
	return col;
}

fragment half4 main()
{
    float t = uni.time;
    // camera
    //float3 ro = float3( 1.0*cos(0.2*t), 0.45, 1.0*sin(0.2*t) );
    float3 ro = float3(1, 0.45, 0);
    float3 ta = float3( 0.0, 0.2, 0.0 );
    // camera-to-world transformation
    float3 up = float3(0,1,0);
    float3 cw = normalize(ta-ro);
    float3 cu = normalize(cross(cw,up));
    float3 cv = cross(cu,cw);

    // screen coordinates
    float aspect = uni.resolution.x / uni.resolution.y;
    float2 p = (2 * frag.uv - 1) * aspect;
    p.y = -p.y;

    // ray direction
    float3 rd = normalize( p.x*cu + p.y*cv + 2.0*cw );

    // render	
    float3 col = render(ro, rd, t);

	// gamma (yes, before accumulation)
    //col = pow(col, vec3(0.4545));
    
    float4 out = float4(col, 1.0);
    return half4(out);
}