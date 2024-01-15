// #genuary7 Progress bar / indicator / loading animation.
float3 hsl_to_rgb(float3 hsl)
{
    // H is normalized between 0...1
    float hue = hsl.x * 360;
    float c = (1-abs(2*hsl.z-1))*hsl.y;
    float h = hue / 60;
    float x = c * (1 - abs(fmod(h,2)-1));
    float3 rgb = float3(0,0,0);
    if (hue<60) {
        rgb = float3(c, x, 0);
    } else if (hue<120) {
        rgb = float3(x, c, 0);
    } else if (hue<180) {
        rgb = float3(0, c, x);
    } else if (hue<240) {
        rgb = float3(0, x, c);
    } else if (hue<300) {
        rgb = float3(x, 0, c);
    } else {
        rgb = float3(c, 0, x);
    }
    float m = hsl.z - c / 2;
    return rgb + m;
}
float3 spinning_wheel(float2 uv, float phase, float r, float s)
{
    const float PI = 3.14159265359;
    float a = atan2(uv.y, uv.x);
    a = atan2(sin(a+phase), cos(a+phase));
    a = 0.5 * a/PI + 0.5;
    float d = length(uv) - r;
    d = pow(saturate(-d),0.35);
    float3 c = hsl_to_rgb(float3(a, s, 0.5));
    return c * d;
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
    const float PI = 3.14159265359;
    float t = fract(0.5 * uni.time);
    float aspect = uni.resolution.x / uni.resolution.y;
    float2 uv = frag.uv * 2 - 1;
    uv.x *= aspect;
    float2x2 r = rotationMatrix(pow(cos(uni.time), 3));
    uv = r * uv;
    float4 out = float4(0.01, 0.02, 0.1, 1);
    out.rgb += spinning_wheel(uv, 2*PI*t, 0.5, 0.6);
    out.rgb += spinning_wheel(uv - float2(0.5, 0.5), 4*PI*t+0.5, 0.35, 0.8);
    out.rgb += spinning_wheel(uv + float2(0.5, 0.5), 2*PI*t+0.25, 0.35, 0.4);
    return half4(out);
}