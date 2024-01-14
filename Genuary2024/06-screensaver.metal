// #genuary6 Screensaver
float nrand(float2 uv)
{
    return fract(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}
float4 randColor(float2 uv)
{
    return float4(nrand(uv), nrand(uv.yx), nrand(float2(uv.x,0.5)), 1.0);
}
float sdCircle(float2 p, float r)
{
    return length(p) - r;
}

float2x2 rotationMatrix(float angle)
{
    float s=sin(angle), c=cos(angle);
    return float2x2(
        float2(c, -s),
        float2(s,  c)
    );
}

fragment half4 main()
{
    float t = uni.time;
    float aspect = uni.resolution.x / uni.resolution.y;
    float2 uv0 = frag.uv * 2 - 1;
    uv0.x *= aspect;
    float2x2 r = rotationMatrix(pow(cos(t), 3));
    uv0 = r * uv0;
    float2 uv1 = 2 * uv0 * (1.5+cos(t));
    float2 uv = fract(uv1) - 0.5;
    float d = sdCircle(uv, 0.5) * exp(-length(uv0));
    float s = uni.scale + 1;
    d = sin(d*s + t) / s;
    d = 0.01 / abs(d);
    float2 uvImage = 0.5 * float2(sin(t) + 1, cos(t) + 1);
    float4 color = randColor(uv0);
    float4 out = float4(d * color.rgb, 1);
    return half4(out);
}