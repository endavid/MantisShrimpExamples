// #genuary20 Generative typography

float2x2 rotationMatrix(float angle)
{
    float s=sin(angle), c=cos(angle);
    return float2x2(
        float2(c, -s),
        float2(s,  c)
    );
}
float4 fill(float d, float width, float3 fill)
{
    float a = saturate(-d + width) / width;
    return float4(fill.rgb, saturate(a));
}
// https://iquilezles.org/articles/distfunctions2d/
float sdUnevenCapsule(float2 p, float r1, float r2, float h)
{
    p.x = abs(p.x);
    float b = (r1-r2)/h;
    float a = sqrt(1.0-b*b);
    float k = dot(p,float2(-b,a));
    if( k < 0.0 ) return length(p) - r1;
    if( k > a*h ) return length(p-float2(0.0,h)) - r2;
    return dot(p, float2(a,b) ) - r1;
}
float3 stroke(float3 out, float t, float t0, float t1, float2 p, float r1, float r2, float h, float angle)
{
    if (t < t0) {
        return out;
    }
    h = h * saturate((t-t0)/(t1-t0));
    float3 black = float3(0.03, 0.11, 0.125);
    float w = 0.01;
    p = rotationMatrix(angle) * p;
    float4 c = fill(sdUnevenCapsule(p, r1, r2, h), w, black);
    return mix(out, c.rgb, c.a);
}


float4 drawScene(float2 uv, float t) {
    float3 white = float3(0.96, 0.94, 0.93);
    float2 p = uv - float2(0.5, 0.5);
    float3 out = white;
    out = stroke(out, t, 0, 0.1, p-float2(-0.22,-0.38), 0.032, 0.02, 0.27, 0.5);
    out = stroke(out, t, 0.1, 0.15, p-float2(-0.23,-0.33), 0.02, 0.028, 0.15, -1.5);
    out = stroke(out, t, 0.15, 0.2, p-float2(-0.07,-0.3), 0.028, 0.02, 0.46, 0.65);
    out = stroke(out, t, 0.2, 0.25, p-float2(-0.23,-0.25), 0.01, 0.02, 0.05, -0.7);
    out = stroke(out, t, 0.25, 0.3, p-float2(-0.28,-0.15), 0.01, 0.02, 0.05, -0.7);
    out = stroke(out, t, 0.3, 0.35, p-float2(0.07,-0.33), 0.02, 0.028, 0.15, -1.5);
    out = stroke(out, t, 0.35, 0.4, p-float2(0.22,-0.32), 0.028, 0.02, 0.15, 0.6);
    out = stroke(out, t, 0.4, 0.5, p-float2(0,-0.3), 0.005, 0.05, 0.48, -0.8);
    out = stroke(out, t, 0.5, 0.55, p-float2(-0.16,0), 0.02, 0.024, 0.3, -1.57);
    out = stroke(out, t, 0.55, 0.6, p-float2(-0.29,0.15), 0.02, 0.024, 0.6, -1.57);
    out = stroke(out, t, 0.6, 0.65, p-float2(0,0.17), 0.02, 0.024, 0.2, 0);
    out = stroke(out, t, 0.65, 0.7, p-float2(-0.01,0.36), 0.026, 0.01, 0.08, 2.2);
    out = stroke(out, t, 0.7, 0.75, p-float2(-0.15,0.25), 0.01, 0.036, 0.11, 0.9);
    out = stroke(out, t, 0.75, 0.8, p-float2(0.15,0.25), 0.01, 0.036, 0.11, -0.9);
    return float4(out, 1.0);
}

fragment half4 main()
{
    float t = fract(uni.time * 0.25);
    float aspect = uni.resolution.x / uni.resolution.y;
    float2 uv = frag.uv;
    uv.x *= aspect;
    float4 out = drawScene(uv, t);
    //out = float4(uv, 0, 1);
    return half4(out);
}
    