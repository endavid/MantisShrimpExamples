// #genuary19 Flocking

constant float PI = 3.1415926536;

float nrand(float2 uv)
{
    return fract(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

// more SDF functions:
// https://iquilezles.org/articles/distfunctions2d/
float sdCircle(float2 p, float r)
{
    return length(p) - r;
}
float sdSegment(float2 p, float2 a, float2 b)
{
    float2 pa = p-a, ba = b-a;
    float h = saturate(dot(pa,ba)/dot(ba,ba));
    return length( pa - ba*h );
}
float flappy(float2 p, float r, float a1, float a2, float t)
{
    float a = mix(a1, a2, sin(t) * 0.5 + 0.5);
    float2 p0 = float2(0);
    float2 p1 = r * float2(cos(a), -sin(a));
    float2 p2 = float2(-p1.x, p1.y);
    float d1 = sdSegment(p, p0, p1);
    float d2 = sdSegment(p, p0, p2);
    return sqrt(d1 * d2);
}

float field(float2 p, float s)
{
    return s/length(p);
}

float3 clouds(float2 p, float t)
{
    float3 white = float3(1);
    float2 c = float2(0.5*sin(0.25*t)+0.5, 1.2);
    float d = field(p-c, 0.3);
    c = float2(0.5*sin(0.3*t+sin(t))+0.5, 1.1);
    d += field(p-c, 0.1);
    return saturate(white * d - 0.8);
}

fragment half4 main()
{
    float t = uni.time;
    float2 uv = frag.uv;
    float2 c = float2(0.5,0.5) + 0.3*float2(cos(t+sin(t)), sin(t+sin(1.3*t+0.2)));
    float wingLength = 0.05;
    float d = flappy(uv-c, wingLength, 0.1, PI/3, t*5);
    float n = uni.scale * uni.scale;
    float r1 = 0.05;
    float r2 = 0.1;
    for (float i = 0; i < n; i+=1)
    {
        float a = mix(-PI/8,PI+PI/8,i/n);
        float rn = nrand(float2(a,a));
        a += mix(-PI/10,PI/10,0.5+0.5*sin(rn*t+a));
        float r = r1 + (r2 + 0.25*sin(t*1.3)+0.25) * rn;
        float2 p = c + r * float2(cos(a), -sin(a));
        float w = mix(0.01, wingLength, rn);
        float di = flappy(uv-p, w, 0.1, PI/3, t*5+0.2*a);
        d = min(di, d);
    }
    float3 azure = float3(0.2, 0.6, 0.9);
    float3 blue = float3(0.05, 0.1, 0.7);
    float3 sky = mix(blue, azure, uv.y);
    float3 cl = clouds(uv, t);
    float4 out = float4((sky + cl) * pow(d,0.25), 1);
    return half4(out);
}