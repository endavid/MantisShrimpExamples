// #genuary11 In the style of Anni Albers (1899-1994).
// I tried to create a weaving pattern with SDFs, but it has lots of popping artefacts...
constant float PI = 3.1415926536;

/// Quaternion Inverse
float4 quatInv(const float4 q) {
    // assume it's a unit quaternion, so just Conjugate
    return float4( -q.xyz, q.w );
}
/// Quaternion multiplication
float4 quatDot(const float4 q1, const float4 q2) {
    float scalar = q1.w * q2.w - dot(q1.xyz, q2.xyz);
    float3 v = cross(q1.xyz, q2.xyz) + q1.w * q2.xyz + q2.w * q1.xyz;
    return float4(v, scalar);
}
/// Apply unit quaternion to vector (rotate vector)
float3 quatMul(const float4 q, const float3 v) {
    float4 r = quatDot(q, quatDot(float4(v, 0), quatInv(q)));
    return r.xyz;
}
/// Returns a quaternion, where
/// xyz: imaginary part; w: real part
float4 createRotation(const float3 start, const float3 end, const float3 up) {
    float e = 1e-6;
    if (length_squared(end - start) < e) {
        // no rotation
        return float4(0,0,0,1);
    }
    // default to opposite vectors
    float angle = PI;
    float3 axis = up;
    if (length_squared(end + start) >= e) {
        // not opposite vectors
        angle = acos(dot(start, end));
        axis = normalize(cross(start, end));
    }
    float w = cos(0.5 * angle);
    axis = sin(0.5 * angle) * axis;
    return float4(axis,w);
}
struct Transform {
    float4 position;    // only xyz actually used
    float4 rotation;    // unit quaternion; w is the scalar
    
    float3 operator* (const float3 v) const {
        return position.xyz + quatMul(rotation, v);
    }
    Transform inverse() {
        float4 r = quatInv(rotation);
        float3 p = quatMul(r, -position.xyz);
        return Transform { float4(p, 1), r };
    }
};
Transform cameraTransform(const float3 viewDirection, const float3 eyePosition, float3 up) {
    float4 r = createRotation(float3(0,0,-1), viewDirection, up);
    float3 p = quatMul(r, eyePosition);
    return Transform { float4(p,1), r };    
}

constant int MAX_MARCHING_STEPS = 255;
constant float MIN_DIST = 0.0;
constant float MAX_DIST = 100.0;
constant float EPSILON = 0.0001;
constant int AO_ITERATIONS = 8;
constant float AO_DISTANCE = 0.05;
constant float AO_POWER = 2.0;
constant float SH_TEXTURE_NEGY = 0.6;
constant float3 aoDir[12] = {
    float3(0.357407, 0.357407, 0.862856),
    float3(0.357407, 0.862856, 0.357407),
    float3(0.862856, 0.357407, 0.357407),
    float3(-0.357407, 0.357407, 0.862856),
    float3(-0.357407, 0.862856, 0.357407),
    float3(-0.862856, 0.357407, 0.357407),
    float3(0.357407, -0.357407, 0.862856),
    float3(0.357407, -0.862856, 0.357407),
    float3(0.862856, -0.357407, 0.357407),
    float3(-0.357407, -0.357407, 0.862856),
    float3(-0.357407, -0.862856, 0.357407),
    float3(-0.862856, -0.357407, 0.357407)
};


// https://github.com/endavid/VidEngine/blob/master/VidFramework/VidFramework/sdk/math/Matrix.swift
float4x4 frustum(float3 bottomLeftNear, float3 topRightFar)
{
    float l = bottomLeftNear.x;
    float r = topRightFar.x;
    float b = bottomLeftNear.y;
    float t = topRightFar.y;
    float n = bottomLeftNear.z;
    float f = topRightFar.z;
    return float4x4(
        float4(2 * n / (r - l), 0, 0, 0),
        float4(0, 2 * n / (t - b), 0, 0),
        float4((r + l) / (r - l), (t + b) / (t - b), -(f + n) / (f - n), -1),
        float4(0, 0, -2 * f * n / (f - n), 0));
}
float4x4 perspective(float fov, float near, float far, float aspect)
{
    float size = near * tan(0.5 * fov);
    return frustum(float3(-size, -size / aspect, near),
                   float3(size, size / aspect, far));
}
float4x4 frustumInverse(float3 bottomLeftNear, float3 topRightFar)
{
    float l = bottomLeftNear.x;
    float r = topRightFar.x;
    float b = bottomLeftNear.y;
    float t = topRightFar.y;
    float n = bottomLeftNear.z;
    float f = topRightFar.z;
    return float4x4(
        float4((r-l)/(2*n), 0, 0, 0),
        float4(0, (t-b)/(2*n), 0, 0),
        float4(0, 0, 0, (n-f)/(2*f*n)),
        float4((r+l)/(2*n), (t+b)/(2*n), -1, (f+n)/(2*f*n))
    );
}
float4x4 perspectiveInverse(float fov, float near, float far, float aspect)
{
    float size = near * tan(0.5 * fov);
    return frustumInverse(float3(-size, -size / aspect, near),
                   float3(size, size / aspect, far));
}
// Coordinate repetitions
float repeatValue(float v, float n) {
    return sign(v) * fmod(v, n) - 0.5 * n;
}
float3 repeatCoords(float3 p, float3 n) {
    return sign(p) * fmod(p, n) - 0.5 * n;
}
float3 repeatX(float3 p, float n) {
    return float3(repeatValue(p.x, n), p.yz);
}
float3 repeatY(float3 p, float n) {
    return float3(p.x, repeatValue(p.y, n), p.z);
}
// SDFs
float vplane(float3 p, float height) {
    return p.y - height;
}
float sinVStrip(float3 p, float width, float depth, float r, float n, float amplitude, float wavelength) {
    float rem = repeatValue(p.y, n);
    float a = (abs(rem) < r) ? 0.5 * amplitude * sin(2 * PI / wavelength * p.y) : 0;
    return max(abs(p.x)-0.5*width, abs(p.z-a)-0.5*depth);
}
float hStrip(float3 p, float height, float depth)
{
    return max(abs(p.y)-0.5*height, abs(p.z)-0.5*depth);
}
/**
 * Signed distance function describing the scene.
 *
 * @returns out.w Absolute value of w indicates the distance to the surface. Sign indicates whether the point is inside or outside the surface,
 * negative indicating inside. out.rgb is the color of the closest surface.
 */
float4 sceneSDF(float3 p) {
    float plane = vplane(p, 0.0);
    float stripDistance = 10;
    float stripDepth = 0.01;
    int order = (int)abs(fmod(p.x/2+0.5,7));
    float offsets[6] = {0, 0, 2, 3, 4, 5};
    float stripsV = sinVStrip(
        repeatX(p-float3(0, offsets[order], stripDistance),4),
        2, stripDepth, 1, 3, 0.15, 3);
    float stripsH = hStrip(
        repeatY(p-float3(2, 0, stripDepth+stripDistance), 2),
        1, stripDepth);
    // colors
    float3 black = float3(45, 48, 48) / 255.0;
    float3 gray = float3(126, 132, 136) / 255.0;
    float3 red = float3(146, 50, 42) / 255.0;
    float3 yellow = float3(254, 234, 73) / 255.0;
    if (plane <= stripsV && plane <= stripsH)
    {
        return float4(gray, plane);
    }
    if (stripsH < stripsV)
    {
        order = (int)abs(fmod(p.y/7+0.5,7));
        float3 colors[7] = {black, black, red, gray, gray, red, gray};
        return float4(colors[order], stripsH);
    }
    order = (int)abs(fmod(p.x/2+0.5,5));
    float3 colors[5] = {yellow, red, red, gray, black};
    return float4(colors[order],stripsV);
}

/**
 * @returns the shortest distance from the eyepoint to the scene surface along
 * the marching direction. If no part of the surface is found between start and end,
 * return end. out.rgb contains the color of the surface.
 *
 * eye: the eye point, acting as the origin of the ray
 * marchingDirection: the normalized direction to march in
 * start: the starting distance away from the eye
 * end: the max distance away from the ey to march before giving up
 */
float4 shortestDistanceToSurface(float3 eye, float3 marchingDirection, float start, float end) {
    float depth = start;
    for (int i = 0; i < MAX_MARCHING_STEPS; i++) {
        float4 d = sceneSDF(eye + depth * marchingDirection);
        float dist = d.w;
        if (dist < EPSILON) {
            return float4(d.rgb, depth);
        }
        depth += dist;
        if (depth >= end) {
            return float4(0,0,0,end);
        }
    }
    return float4(0,0,0,end);
}
/**
 * Using the gradient of the SDF, estimate the normal on the surface at point p.
 */
float3 estimateNormal(float3 p) {
    return normalize(float3(
      sceneSDF(float3(p.x + EPSILON, p.y, p.z)).w
        - sceneSDF(float3(p.x - EPSILON, p.y, p.z)).w,
      sceneSDF(float3(p.x, p.y + EPSILON, p.z)).w
        - sceneSDF(float3(p.x, p.y - EPSILON, p.z)).w,
      sceneSDF(float3(p.x, p.y, p.z  + EPSILON)).w
        - sceneSDF(float3(p.x, p.y, p.z - EPSILON)).w
    ));
}
// http://harmonikr.endavid.com
float2 toSampleSH(float3 n) {
    float t = SH_TEXTURE_NEGY;
    float2 uv;
    if (n.y > 0) {
        uv = float2(n.x * t, n.z * t);
    } else {
        uv = sign(n.xz) * float2((t-1.0)*n.x + 1.0, (t-1.0)*n.z + 1.0);
    }
    return uv * 0.5 + 0.5;
}

float3x3 alignMatrix(float3 dir) {
    float3 f = normalize(dir);
    float3 s = normalize(cross(f, float3(0.48, 0.6, 0.64)));
    float3 u = cross(s, f);
    return float3x3(u, s, f);
}

float ao(const float3 p, const float3 n) {
    float dist = AO_DISTANCE;
    float occ = 1.0;
    for (int i = 0; i < AO_ITERATIONS; ++i) {
        occ = min(occ, sceneSDF(p + dist * n).w / dist);
        dist *= AO_POWER;
    }
    occ = max(occ, 0.0);
    return occ;
}

float computeOcclusion(const float3 p, const float3 n) {
    float3x3 mat = alignMatrix(n);
    float occ = 0.0;
    for (int i = 0; i < 12; ++i) {
        float3 m = mat * aoDir[i];
        occ += ao(p, m) * (0.5 + 0.5 * dot(m, float3(0.0, 0.0, 1.0)));
    }
    occ = pow(0.7 * occ, 0.5);
    return saturate(occ);
}

float3 skyColor(float3 p)
{
    float3 black = float3(25, 25, 25) / 255.0;
    float3 gray = float3(109, 115, 124) / 255.0;
    float3 white = float3(1,1,1);
    int order = (int)abs(fmod(p.y/14+0.5,4));
    float3 colors[4] = {white, black, white, gray};
    return colors[order];
}

fragment half4 main()
{
    // view position at far (z=+1) plane    
    float4 vp = float4(2 * frag.uv - 1, 1, 1.0);
    vp.y = -vp.y;
    
    float t = uni.time;
    float aspect = uni.resolution.x / uni.resolution.y;
    float fov = 90 * PI / 180;
    float4x4 invP = perspectiveInverse(fov, 0.1, 100, aspect);
    float3 camStart = float3(-50, 50, 20);
    float3 position = float3(0, 30.0 * cos(0.5*t), 5.0 * sin(t)) + camStart;
    float3 viewDir = normalize(float3(0.1*sin(t),0.1*cos(0.5*t),-1));
    auto cam = cameraTransform(viewDir,position,float3(0,1,0));
    float3 eye = cam.position.xyz;
    auto viewTr = cam.inverse();
    float4 world = invP * vp;
    world.xyz = world.xyz / world.w;
    world.xyz = viewTr * world.xyz;
    float3 ray = world.xyz - eye;
    float3 dir = normalize(ray);
    float4 d = shortestDistanceToSurface(eye, dir, MIN_DIST, MAX_DIST);
    float dist = d.w;
    if (dist > MAX_DIST - EPSILON) {
        // Didn't hit anything -> sky
        float4 out = float4(gamma_to_linear(skyColor(world.xyz)), 1.0);
        return half4(out);
    }
    // The closest point on the surface to the eyepoint along the view ray
    float3 p = eye + dist * dir;
    float3 n = estimateNormal(p);
    const float3 lightDir = normalize(float3(0,1,1));
    float shade = dot(lightDir, n);
    float3 color = gamma_to_linear(d.rgb);
    float4 out = float4(color * shade, 1);
    //out.rgb = n * 0.5 + 0.5;
    float occ = computeOcclusion(p, n);
    out.rgb *= occ;
    //out.rgb = float3(uv, 0);
    //out.rgb = world.rgb;
    //out.rgb = ray;
    //out.rgb = ray;
    //out.rgb = vp.rgb;
    //out.rgb = float3(M[0][0], M[1][1], M[2][2]);
    return half4(out);
}