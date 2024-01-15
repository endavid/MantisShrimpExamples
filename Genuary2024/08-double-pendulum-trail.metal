// #genuary8 Chaotic system.
// This implementation is not chaotic because
// I didn't take into account the center of mass
// https://en.wikipedia.org/wiki/Double_pendulum
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
float4 paint(float d, float width, float4 color) {
    float a = pow(saturate(width-abs(d))/width, 2);
    return a * color;
}
float4 fill(float d, float width, float4 color) {
    float a = saturate(pow(saturate(width-d)/width, 2));
    return a * color;
}

// simple harmonic motion
float amplitude(float t, float a0, float len, float phi)
{
    const float g = 10;
    float k = sqrt(g/len);
    return a0 * cos(k * t + phi);
}
float2 pendulum(float t, float2 start, float a0, float len, float phi)
{
    float theta = amplitude(t, a0, len, phi);
    float2 bob = len * float2(sin(theta), cos(theta)) + start;
    return bob;
}
fragment half4 main()
{
    float t = uni.time;
    float4 white = float4(243, 238, 235, 255) / 255;
    float4 black = float4(20, 8, 6, 255) / 255;
    float4 red = float4(0.9, 0, 0, 1.0);
    float4 orange = float4(0.9, 0.2, 0, 1.0);
    float a0 = 0.5;
    float l1 = 0.3;
    float l2 = 0.35;
    float aspect = uni.resolution.x / uni.resolution.y;
    float2 uv = frag.uv;
    uv.x *= aspect;
    float4 out = white;
    float4 trail = float4(0);
    for (float n = uni.scale; n > 0; n-=1)
    {
        float2 start = float2(0.5, 0);
        float t_i = t - n * 0.05;
        float2 bob = pendulum(t_i, start, a0, l1, 0);
        start = bob;
        bob = pendulum(t_i, start, 1.2, l2, 2);
        float a = (uni.scale-n)/uni.scale;
        float d = sdCircle(uv - bob, 0.05 * a + 0.05);
        float4 c = fill(d, 0.01, orange * (0.7*a+0.3));
        trail = mix(trail, c, c.a);
    }
    out.rgb = mix(out.rgb, trail.rgb, trail.a);
    float2 start = float2(0.5, 0);
    float2 bob = pendulum(t, start, a0, l1, 0);
    float d = sdSegment(uv, start, bob);
    start = bob;
    bob = pendulum(t, start, 1.2, l2, 2);
    d = min(d, sdSegment(uv, start, bob));
    float4 lines = paint(d, 0.01, black);
    d = sdCircle(uv - bob, 0.1);
    trail = fill(d, 0.01, red);
    out.rgb = mix(out.rgb, lines.rgb, lines.a);
    out.rgb = mix(out.rgb, trail.rgb, trail.a);
    return half4(out);
}