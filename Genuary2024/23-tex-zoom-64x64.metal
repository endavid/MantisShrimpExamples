// #genuary23 64x64

float sdBox(float2 p, float2 b, float roundness)
{
    float2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0) - roundness;
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
    float2x2 r = rotationMatrix(3.1416*0.5*cos(2*t));
    uv0 = mix(0.5, 1, saturate(sin(t)+1)) * uv0;
    uv0 = r * uv0;
    float s = mix(0.5, 2, saturate(2*sin(0.5*t)-1)); 
    float2 uv = fract(32 * uv0) - 0.5;
    //uv = r * uv;
    float x = mix(0.005, 0.2, saturate(2*sin(2*t)));
    float y = mix(0.005, 0.2, saturate(2*sin(t)-1));
    float d = sdBox(uv, float2(0.1,0.1), 0) * exp(-length(uv0));
    float ss = uni.scale + 1;
    d = sin(d*ss + t) / ss;
    d = 0.01 / abs(d);
    float2 texcoord = 0.5 * (uv0.xy + 1); // = frag.uv when not transformed
    float4 color = texB.sample(sam, texcoord);
    float4 out = float4(d * color.rgb, 1);
    return half4(out);
}