// #genuary3 Droste effect
float2x2 rotationMatrix(float angle)
{
    float s=sin(angle), c=cos(angle);
    return float2x2(
        float2(c, -s),
        float2(s,  c)
    );
}
// SDF https://iquilezles.org/articles/distfunctions2d/
float sdBox(float2 p, float2 b)
{
    float2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}
float sdCircle(float2 p, float r)
{
    return length(p) - r;
}
float sdArc(float2 p, float aperture, float ra, float rb)
{
    float2 sc = float2(sin(aperture), cos(aperture));
    p.x = abs(p.x);
    return ((sc.y*p.x>sc.x*p.y) ? length(p-sc*ra): 
                                  abs(length(p)-ra)) - rb;
}
float sdTrapezoid(float2 p, float r1, float r2, float he)
{
    float2 k1 = float2(r2,he);
    float2 k2 = float2(r2-r1,2.0*he);
    p.x = abs(p.x);
    float2 ca = float2(p.x-min(p.x,(p.y<0.0)?r1:r2), abs(p.y)-he);
    float2 cb = p - k1 + k2*saturate(dot(k1-p,k2)/dot(k2,k2));
    float s = (cb.x<0.0 && ca.y<0.0) ? -1.0 : 1.0;
    return s*sqrt( min(dot(ca,ca),dot(cb,cb)) );
}
float round(float d, float r)
{
  return d - r;
}
float4 fill(float d, float width, float4 line, float4 fill) {
    if (-d > width) {
        return fill;
    }
    float a = saturate(-d + width) / width;
    return line * a;
}
float4 drawScene(float2 uv) {
    float4 yellow = float4(0.96, 0.9, 0.25, 1.0);
    float4 black = float4(0.03, 0.11, 0.125, 1.0);
    float4 blue = float4(0.68, 0.74, 0.8, 1.0);
    float4 red = float4(0.62, 0.008, 0.035, 1.0);
    float4 white = float4(0.86, 0.97, 0.93, 1.0);
    float4 skin = float4(0.92, 0.8, 0.71, 1.0);
    float4 out = blue;
    // box
    float2 p = uv - float2(0.5, 0.5);
    float4 c = fill(sdBox(p, float2(0.4,0.45)), 0.002, black, red);
    out = mix(out, c, c.a);
    // C
    p = uv - float2(0.3, 0.19);
    float2x2 rot = rotationMatrix(1.5);
    p = rot * p;
    c = fill(sdArc(p, 2.1, 0.06, 0.025), 0.005, black, yellow);
    out = mix(out, c, c.a);
    // A
    p = uv - float2(0.41, 0.2);
    c = fill(sdTrapezoid(p, 0.01, 0.05, 0.08), 0.005, black, yellow);
    out = mix(out, c, c.a);
    // C
    p = uv - float2(0.53, 0.2);
    p = rot * p;
    c = fill(sdArc(p, 2.1, 0.05, 0.025), 0.005, black, yellow);
    out = mix(out, c, c.a);
    // A
    p = uv - float2(0.635, 0.2);
    c = fill(sdTrapezoid(p, 0.01, 0.05, 0.08), 0.005, black, yellow);
    out = mix(out, c, c.a);
    // O
    p = uv - float2(0.76, 0.2);
    c = fill(sdCircle(p, 0.08), 0.005, black, yellow);
    out = mix(out, c, c.a);
    c = fill(sdCircle(p, 0.035), 0.005, black, red);
    out = mix(out, c, c.a);
    // hat
    p = uv - float2(0.635, 0.4);
    c = fill(sdTrapezoid(p, 0.02, 0.15, 0.08), 1e-5, white, white);
    out = mix(out, c, c.a);
    // arm
    p = uv - float2(0.54, 0.60);
    rot = rotationMatrix(-1);
    p = rot * p;
    c = fill(sdArc(p, 2.1, 0.08, 0.04), 1e-5, black, black);
    out = mix(out, c, c.a);
    // body
    p = uv - float2(0.635, 0.8);
    c = fill(sdTrapezoid(p, 0.09, 0.15, 0.15), 1e-5, black, black);
    out = mix(out, c, c.a);
    p = uv - float2(0.635, 0.6);
    c = fill(sdTrapezoid(p, 0.12, 0.09, 0.12), 1e-5, black, black);
    out = mix(out, c, c.a);
    p = uv - float2(0.635, 0.8);
    c = fill(sdTrapezoid(p, 0.04, 0.1, 0.15), 1e-5, white, white);
    out = mix(out, c, c.a);
    p = uv - float2(0.635, 0.6);
    c = fill(sdTrapezoid(p, 0.08, 0.04, 0.11), 1e-5, white, white);
    out = mix(out, c, c.a);
    // arm
    p = uv - float2(0.75, 0.61);
    p = rot * p;
    c = fill(sdArc(p, 2.1, 0.08, 0.04), 1e-5, black, black);
    out = mix(out, c, c.a);
    // face
    p = uv - float2(0.635, 0.47);
    c = fill(sdCircle(p, 0.07), 0.001, black, skin);
    out = mix(out, c, c.a);
    // hands
    p = uv - float2(0.66, 0.62);
    c = fill(sdCircle(p, 0.03), 0.001, black, skin);
    out = mix(out, c, c.a);
    p = uv - float2(0.46, 0.62);
    c = fill(sdCircle(p, 0.03), 0.001, black, skin);
    out = mix(out, c, c.a);
    return out;
}
float2 uvRectangle(float2 uv, float4 aabb) {
    if (uv.x < aabb.x || uv.x > aabb.z || uv.y < aabb.y || uv.y > aabb.w) {
        return uv;
    }
    float2 size = aabb.zw - aabb.xy;
    return (uv - aabb.xy) / size;
}
fragment half4 main()
{
    float t = fract(uni.time);
    t = pow(t, 0.7);
    float aspect = uni.resolution.x / uni.resolution.y;
    float2 uv = frag.uv;
    uv.x *= aspect;
    float4 aabb = float4(0.1, 0.4, 0.4, 0.7);
    float2 size = aabb.zw - aabb.xy;
    float2 center = size / 2 + aabb.xy;
    float2 offset = center - size.y*float2(0.5, 0.5);
    float2 zoomed = size.y*uv + offset;
    uv = mix(uv, zoomed, t);
    for (float n = 0; n < uni.scale; n += 1) {
        uv = uvRectangle(uv, aabb);
    }
    float4 out = drawScene(uv);
    //out = float4(uv, 0, 1);
    return half4(out);
}