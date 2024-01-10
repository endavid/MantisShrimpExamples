// #genuary1 Particles, lots of them.
float nrand(float2 uv)
{
    return fract(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
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
    float2x2 rot = rotationMatrix(cos(t));
    uv0 = rot * uv0;
    float zoom = exp(abs(sin(t)));
    float2 uv = fract(zoom * uv0) - 0.5;
    float2 uvImage = frag.uv;
    float4 color = texA.sample(sam, uvImage);
    float dSum = 0;
    for (float x=-0.5; x <= 0.5; x += 0.005) {
      float r = nrand(float2(x,x));
      float2 sc = float2(x + 0.1 * sin(t*4*(1+r)), cos(t*(1+r)));
      float d = sdCircle(uv - sc, 0.015*r);
      d = 0.0015 / abs(d);
      dSum += d;
    }
    float4 out = float4(dSum * color.rgb, 1);
    return half4(out);
}