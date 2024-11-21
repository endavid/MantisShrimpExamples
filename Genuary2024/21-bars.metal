// #genuary21 Use a library that you haven’t used before.
// I haven't used any special library in this shader,
// but I added support for video recording to MantisShrimp
// using AVFoundation, which I hadn't done before

float nrand(float2 uv)
{
    return fract(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

float sdBox(float2 p, float2 b)
{
    float2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
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
    float2x2 r = rotationMatrix(0.1*cos(t+1.57));
    uv0 = r * uv0;
    float2 uv = float2(fract(uni.scale * uv0.x) - 0.5, uv0.y);
    float x = 0.5 * (uv0.x + 1); // = frag.uv when not transformed
    float index = floor(uni.scale * 2 * x) / (uni.scale*2);
    float phase = nrand(float2(0.5, index));
    float height = 0.25 * sin(8*t + 2 * t * cos(phase)) + 0.5;
    float d = sdBox(uv, float2(0.1, height));
    d = d + 0.1*(-1+sin(t));
    d = 0.01 / abs(d);
    float2 uvImage = 0.5 * float2(sin(t) + 1, cos(t) + 1);
    float4 color = float4(0.5*cos(phase+2*t)+0.5,0.5*cos(phase+4*t+0.7)+0.5,1,1);
    float4 out = float4(d * color.rgb, 1);
    return half4(out);
}