// #genuary13 Wobbly function day
// https://piterpasma.nl/articles/wobbly
constant float PI = 3.1415926536;

float nrand(float2 uv)
{
    return fract(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

float2 wobblyBlob(float2 p, float t)
{
    float d = length(p);
    float angle = atan2(p.y, p.x);
    float2 da = float2(0.2 + 0.1 * sin(t), 0.2 + 0.1 * cos(t));
    p.x = d * cos(angle + da.x * sin(2*t+3*p.x+sin(5*p.x+2*t)));
    p.y = 0.8 * d * sin(angle + da.y * sin(3*t+4*p.y+2*p.x));
    return p;
}

float sphereSDF(float2 p, float r)
{
    return length(p) - r;
}

float stripes(float2 p, float angle, float r1, float r2)
{
    float l = length(p);
    if (l > r2) {
        return l - r2;
    }
    if (l < r1) {
        return r1 - l;
    }
    float a = PI + atan2(p.y, p.x);
    float d = fmod(a, angle) / angle;
    d = 4*pow(d-0.5,2)-0.25;
    float d1 = (l-r2)/(r1-r2);
    d *= d1;
    //d *= -4 * pow(0.5-d1,2)+1;
    return d;
}

float3 kiwiGradient(float d)
{
    float3 white = float3(0.9,0.9,0.3);
    float3 darkGreen = float3(0,0.1,0);
    float3 green = float3(0.2,0.7,0.01);
    float3 brown = float3(0.1, 0.05, 0);
    float3 black = float3(0.01,0.01,0);
    float3 bg = float3(0.05,0.01,0.005);
    float3 colors[6] = {
        bg, black, brown, green, darkGreen, white
    };
    float thresholds[6] = {
        0.5, 0.01, -0.01, -0.25, -0.35, -0.5
    };
    float3 color = bg;
    for (int i = 0; i < 5; i++)
    {
        float a = thresholds[i];
        float b = thresholds[i+1];
        if (d <= a) {
            float t = (d-a) / (b-a);
            color = mix(colors[i], colors[i+1], t);
            continue;
        }
    }
    return color;
}

float4 stripeGradient(float d, float threshold)
{
    float3 darkGreen = float3(0,0.1,0);
    float3 black = float3(0,0,0);
    float a = pow(saturate(-d), 0.5);
    if (a < threshold) {
        return float4(darkGreen, a);
    }
    return float4(black, 1.0);
}

float2x2 rotationMatrix(float angle)
{
    float s=sin(angle), c=cos(angle);
    return float2x2(
        float2(c, -s),
        float2(s,  c)
    );
}

float2 scaleAndRotate(float2 uv, float t)
{
    uv *= mix(0.5, 4, 4 * pow(fract(t*0.1)-0.5,2));
    float2x2 rot = rotationMatrix(cos(t));
    uv = rot * uv;
    uv = 2*fract(0.5*uv+0.5)-1;
    return uv;
}

fragment half4 main()
{
    float t = uni.time;
    float aspect = uni.resolution.x / uni.resolution.y;
    float2 uv0 = frag.uv * 2 - 1;
    uv0.x *= aspect;
    //uv0 = scaleAndRotate(uv0, t);
    float2 p = wobblyBlob(uv0, t);
    float d1 = sphereSDF(p, 0.5);
    float d2 = stripes(p, PI/10, 0.15, 0.4);
    //d = (PI + atan2(uv0.y, uv0.x)) / PI / 2.0;
    float4 out = float4(0,0,0,1);
    float3 kiwi = kiwiGradient(d1);
    float4 stripes = stripeGradient(d2, 0.35);
    out.rgb = mix(kiwi, stripes.rgb, stripes.a);
    //out = stripes;
    return half4(out);
}