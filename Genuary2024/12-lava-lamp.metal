// #genuary12 Lava lamp
constant float PI = 3.1415926536;

float nrand(float2 uv)
{
    return fract(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

float field(float2 p, float s)
{
    return s/length(p);
}

float blob(float2 center, float scale, int satelliteCount, float t)
{
    float n = float(satelliteCount);
    float step = 2.0 * PI / n;
    float s = scale / n;
    float d = 0;
    for (int i = 0; i < satelliteCount; i++)
    {
        float a = float(i) * step;
        float si = (1.0 + nrand(float2(0,a))) * s;
        float r = nrand(float2(a,a));
        float phase = t * (0.1+r);
        a += phase;
        float2 p = si * float2(cos(a), sin(a));
        d += field(center - p, si);
    }
    return d;
}

float4 background(float2 p, float t)
{
    float3 darkBlue = float3(0.001, 0.005, 0.05);
    float3 blue = float3(0.005, 0.02, 0.1);
    float2 c = float2(sin(t), cos(t)) * 2;
    float d = field(p-c, 3);
    float3 color = darkBlue + saturate(blue * d - 0.2);
    return float4(color, 1);
}

float stars(float2 p, int count, float t)
{
    float n = float(count);
    float step = 1.0/n;
    float3 out = float3(0);
    float d = 0;
    for (int i = 0; i < n; i++)
    {
        float a = float(i) * step;
        float r1 = nrand(float2(a,a));
        float r2 = nrand(float2(a,0.5));
        float2 c = float2(1.5 * r1 - 0.75, 1.8 * r2 - 0.9);
        c += float2(0.1*r2*sin(t+r1), 0.1*r1*cos(t+r2));
        float di = field(p-c, 0.01);
        d += di;
    }
    return d;
}

fragment half4 main()
{
    float t = uni.time;
    float aspect = uni.resolution.x / uni.resolution.y;
    float2 uv0 = frag.uv * 2 - 1;
    uv0.x *= aspect;
    float2 bottom = float2(0,1.2);
    float tBig = 0.5*t;
    float direction = cos(tBig); // upwards when positive
    float2 a = float2(0.4 * sin(t*0.7), 0.6 * direction + 0.25);
    float2 b = float2(0.2 * cos(t*0.3), 0.7 * sin(tBig) + 0.2);
    float2 c = float2(0.1 * cos(t*0.2), 0.7 * sin(t*0.25) + 0.2);
    float z = 0.5 - direction * 0.5;
    float d0 = field(uv0-bottom, 0.3);
    float d1 = blob(uv0-a, 0.2 + 0.1 * (1-z), 4, t);
    float d2 = blob(uv0-b, 0.2 + 0.1 * z, 3, t);
    float d3 = blob(uv0-c, 0.1, 2, t);
    float th = 0.2 * uni.scale;
    float d = saturate(d0 + d1 + d2 - th);
    float3 green = float3(0.001,0.9,0.002);
    float3 yellow = float3(0.9, 0.9, 0.6);
    float4 out = background(uv0, t);
    out.rgb *= stars(uv0, 20, t);
    float m = pow(z, 16.0);
    float3 c1 = mix(green, yellow, m);
    float3 c2 = mix(yellow, green, m);
    out.rgb += saturate(d0 * yellow + d1 * c1 + d2 * c2 + d3 * yellow - th);
    out.gb += 0.7*saturate(stars(uv0, 5, t*1.5)-0.8);
    return half4(out);
}