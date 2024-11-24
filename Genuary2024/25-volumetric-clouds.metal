// #Genuary25 Raymarching clouds
// port from https://www.shadertoy.com/view/WdXGRj
// slightly tweaked colors for sunset.

// noise
// Volume raycasting by XT95
// https://www.shadertoy.com/view/lss3zr
float hash(float n)
{
    return fract(sin(n)*43758.5453);
}

float noise(float3 x)
{
    float3 p = floor(x);
    float3 f = fract(x);
    f = f*f*(3.0-2.0*f);
    float n = p.x + p.y*57.0 + 113.0*p.z;
    float res = mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                        mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
                    mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                        mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
    return res;
}
float fbm(float3 p)
{
    const float3x3 m = float3x3(
         0.00,  0.80,  0.60,
        -0.80,  0.36, -0.48,
        -0.60, -0.48,  0.64 );
    float f;
    f  = 0.5000*noise(p); p = m*p*2.02;
    f += 0.2500*noise(p); p = m*p*2.03;
    f += 0.12500*noise(p); p = m*p*2.01;
    f += 0.06250*noise(p);
    return f;
}

// SDF scene
// -------------
float stepUp(float t, float len, float smo)
{
  float tt = fmod(t += smo, len);
  float stp = floor(t / len) - 1.0;
  return smoothstep(0.0, smo, tt) + stp;
}

// iq's smin
float smin(float d1,float d2, float k)
{
    float h = clamp(0.5 + 0.5*(d2-d1)/k, 0.0, 1.0);
    return mix(d2, d1, h) - k*h*(1.0-h);
}

float sdTorus(float3 p, float2 t)
{
  float2 q = float2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

float map(float3 p, float time)
{
    float3 q = p - float3(0, 0.5, 1.0) * time;
    float f = fbm(q);
    float s1 = 1.0 - length(p * float3(0.5, 1.0, 0.5)) + f * 2.2;
    float s2 = 1.0 - length(p * float3(0.1, 1.0, 0.2)) + f * 2.5;
    float torus = 1. - sdTorus(p * 2.0, float2(6.0, 0.005)) + f * 3.5;
    float s3 = 1.0 - smin(smin(
                           length(p * 1.0 - float3(cos(time * 3.0) * 6.0, sin(time * 2.0) * 5.0, 0.0)),
                           length(p * 2.0 - float3(0.0, sin(time) * 4.0, cos(time * 2.0) * 3.0)), 4.0),
                           length(p * 3.0 - float3(cos(time * 2.0) * 3.0, 0.0, sin(time * 3.3) * 7.0)), 4.0) + f * 2.5;
    
    float t = fmod(stepUp(time, 4.0, 1.0), 4.0);
    
	float d = mix(s1, s2, clamp(t, 0.0, 1.0));
    d = mix(d, torus, clamp(t - 1.0, 0.0, 1.0));
    d = mix(d, s3, clamp(t - 2.0, 0.0, 1.0));
    d = mix(d, s1, clamp(t - 3.0, 0.0, 1.0));
    
	return min(max(0.0, d), 1.0);
}

// -------------


// Reference
// https://shaderbits.com/blog/creating-volumetric-ray-marcher
float4 cloudMarch(float3 p, float3 ray, float3 light, float jitter, float t)
{
    constexpr int MAX_STEPS = 48;
    constexpr int SHADOW_STEPS = 8;
    constexpr int VOLUME_LENGTH = 15;
    constexpr int SHADOW_LENGTH = 2;
    float density = 0;
    float stepLength = VOLUME_LENGTH / float(MAX_STEPS);
    float shadowStepLength = SHADOW_LENGTH / float(SHADOW_STEPS);
    float4 sum = float4(0,0,0,1);
    float3 pos = p + ray * jitter * stepLength;
    const float3 sunColor = float3(1, 0.3, 0.1);
    const float3 skyColor = float3(0.15, 0.15, 0.25);
    for (int i = 0; i < MAX_STEPS; i++)
    {
        if (sum.a < 0.1)
        {
            break;
        }
        float d = map(pos, t);
        if (d > 0.001)
        {
            float3 lpos = pos + light * jitter * shadowStepLength;
            float shadow = 0;
            for (int s = 0; s < SHADOW_STEPS; s++)
            {
                lpos += light * shadowStepLength;
                float lsample = map(lpos, t);
                shadow += lsample;
            }
            density = saturate(20.0 * d / float(MAX_STEPS));
            float s = exp((-shadow/float(SHADOW_STEPS)) * 3.0);
            sum.rgb += float3(s * density) * sunColor * sum.a;
            sum.a *= 1.0 - density;
            sum.rgb += exp(-map(pos + float3(0,0.25,0), t) * 0.2) * density * skyColor * sum.a;
        }
        pos += ray * stepLength;
    }
    return sum;
}

float3x3 camera(float3 ro, float3 ta, float cr)
{
    float3 cw = normalize(ta - ro);
    float3 cp = float3(sin(cr), cos(cr), 0);
    float3 cu = normalize(cross(cw, cp));
    float3 cv = normalize(cross(cu, cw));
    return float3x3(cu, cv, cw);
}

fragment half4 main()
{
    float t = uni.time;
    float aspect = uni.resolution.x / uni.resolution.y;
    float2 p = frag.uv * 2 - 1;
    p.x *= aspect;
    p.y = -p.y;
    float jitter = hash(p.x + p.y * 57.0 + t);
    float3 ro = float3(cos(t * 0.333) * 8.0, -5.5, sin(t * 0.333) * 8.0);
    float3 ta = float3(0, 1, 0);
    float3x3 c = camera(ro, ta, 0);
    float3 ray = c * normalize(float3(p, 1.75));
    // sun direction
    const float3 light = normalize(float3(1, -1.0, -2));
    // ray march
    float4 col = cloudMarch(ro, ray, light, jitter, t);
    // mix color
    const float3 skyBottom = float3(0.2, 0.2, 0.3);
    const float3 skyTop = float3(0.2, 0.3, 0.45);
    const float3 dirColor = 0.9 * float3(1,0.2,0.1);
    float3 result = col.rgb + mix(skyBottom, skyTop, p.y + 0.75) * (col.a);
    float sundot = saturate(dot(ray,light));
    result += dirColor*pow(sundot, 4.0);
    // in MantisShrimp, use LinearRGB, so no need to apply the gamma.
    //result = pow(result, float3(1.0/2.2));
    float4 out = float4(result, 1);
    //out = col;
    return half4(out);
}