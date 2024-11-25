// #genuary27 Code for one hour
// I googled interesting functions and I found this:
//   https://en.wikipedia.org/wiki/Quasicrystal

constant float PI = 3.1415926536;

float quasicrystal(float2 p, float scale, float angleOffset, int waveCount)
{
    float value = 0;
    for (int i = 0; i < waveCount; i++)
    {
        // spread angles evenly
        float angle = angleOffset + float(i) * PI * 2 / float(waveCount);
        float2 direction = float2(cos(angle), sin(angle));
        float wave = cos(dot(p, direction) * scale);
        value += wave;
    }
    value = value / float(waveCount) * 0.5 + 0.5;
    return value;
}

fragment half4 main()
{
    float t = uni.time;
    float aspect = uni.resolution.x / uni.resolution.y;
    float2 uv = frag.uv * 2 - 1;
    uv.x *= aspect;
    
    constexpr float cycleSecs = 20; // time to loop
    float t2 = t * 2 * PI / cycleSecs;
    
    float scale = 2 * sin(t2*2) + 4; 
    float darken = exp(-length(uv));
    float d = quasicrystal(uv, 10 * scale, t2, 7) * darken;
    float d2 = quasicrystal(uv, 9 * scale, t2, 3) * darken;

            
    // get outlines
    float s = 4;
    d = sin(d*s+t)/s;
    d = 0.01 / abs(d);
    //d2 = sin(d2*s+t)/s;
    //d2 = 0.01 / abs(d2);
    
    // compute color
    float3 c1 = float3(d * 0.1, d * 0.5, pow(d,8));
    float3 c2 = 0.1 * float3(d2, 0.5 * d2, pow(d2, 2));
    float3 color = mix(c1, c2, d2 * 0.5);
    float4 out = float4(color, 1);
    return half4(out);
}