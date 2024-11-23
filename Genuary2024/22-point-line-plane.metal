// #genuary22 Point-line-plane

float sdBox(float2 p, float2 b, float roundness)
{
    float2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0) - roundness;
}

fragment half4 main()
{
    float t = uni.time;
    float aspect = uni.resolution.x / uni.resolution.y;
    float2 uv0 = frag.uv * 2 - 1;
    uv0.x *= aspect;
    float s = mix(0.5, 2, saturate(2*sin(0.5*t)-1)); 
    float2 uv = fract(s * uv0 -0.5) - 0.5;
    float x = mix(0.005, 0.2, saturate(2*sin(2*t)));
    float y = mix(0.005, 0.2, saturate(2*sin(t)-1));
    float d = sdBox(uv, float2(x,y), 0) * exp(-length(uv0));
    d = 0.01 / abs(d);
    float4 color = float4(1,2*sin(2*t),1,1);
    float4 out = float4(d * color.rgb, 1);
    return half4(out);
}