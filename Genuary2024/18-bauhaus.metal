// #genuary18 Bauhaus

float nrand(float2 uv)
{
    return fract(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

// more SDF functions:
// https://iquilezles.org/articles/distfunctions2d/
float sdCircle(float2 p, float r)
{
    return length(p) - r;
}

float border(float2 p, float r, float w)
{
    float2 d = (abs(p) - r)/w;
    return saturate(1.0 - max(d.x, d.y));
}
float border(float c, float r, float w)
{
    float d = (abs(c) - r)/w;
    return saturate(d);
}

fragment half4 main()
{
    float t = uni.time;
    float aspect = uni.resolution.y / uni.resolution.x;
    float2 uv0 = frag.uv * 2 - 1;
    uv0.y = uv0.y * aspect + 0.25;
    float2 uv = fract(2 * uv0) - float2(0.5,0.5);
    // divide area in 4x5 regions, so I can get a unique
    // random value for each sector
    float2 grid = float2(4,5);
    float2 uvBig = floor(grid * frag.uv)/grid;
    float numVariations = 10;
    uvBig += floor(numVariations * fract(0.1*t)) / numVariations;
    float r = nrand(uvBig);
    float b = border(uv, 0.45, 0.05);
    bool horizontal = true;
    if (r < 0.15) {
        uv.x = -sign(uv.x) * 0.5 + uv.x;
    } else if (r < 0.4) {
        uv.y = -sign(uv.y) * 0.5 + uv.y;
        horizontal = false;
    } else if (r < 0.7) {
        b *= border(uv.x, 0, 0.05);
    } else {
        b *= border(uv.y, 0, 0.05);
        horizontal = false;
    } 
    b = step(0.4, b);
    float d = sdCircle(uv, 0.48);
    float2 d2 = pow(saturate(float2(d,-d)), 0.02) * b;
    // color choise
    float3 red = float3(196, 71, 38) / 255.0;
    float3 white = float3(226, 219, 210) / 255.0;
    float3 color = mix(white, red, d2.y);
    float rc = nrand(uvBig.yx);
    if (rc < 0.2) {
        float3 beige = float3(188, 149, 80) / 255.0;
        float3 black = float3(35, 35, 23) / 255.0;
        float3 rcolor = rc < 0.1 ? beige : black;
        if (horizontal) {
            if (uv.x > 0) {
                color = mix(white, rcolor, d2.y);
            }
        } else {
            if (uv.y > 0) {
                color = mix(white, rcolor, d2.y);
            }
        }
    }
    //float s = uni.scale + 1;
    //d = sin(d*s + t) / s;
    //d = 0.01 / abs(d);
    float4 out = float4(color, 1);
    //out.rgb = float3(b,b,b);
    //out.rgb = float3(d,-d,0);
    //out.rgb = float3(d2,0);
    //out.xy = uvBig;
    //out.xy = uv;
    //out.xy = fract(float2(2,2)*(uv0+float2(0,0.25)))-0.5;
    return half4(out);
}