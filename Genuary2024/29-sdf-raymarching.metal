// #genuary29 Signed Distance Functions
// This is the shader I used in #palettist about screen http://palettist.endavid.com
// The irradiance map is created with #harmonikr http://harmonikr.endavid.com
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
    float3 p = eyePosition;
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

// SDFs
float vplane(float3 p, float height) {
    return p.y - height;
}

float cubeSDF(float3 p, float3 size) {
    return length(max(abs(p)-size,0.0));
}

/**
 * Signed distance function describing the scene.
 *
 * @returns out.w Absolute value of w indicates the distance to the surface. Sign indicates whether the point is inside or outside the surface,
 * negative indicating inside.
 * out.xy is the texture coordinate to sample for color.
 */
float4 sceneSDF(float3 p) {
    float plane = vplane(p, 0.0);
    float3 c = float3(3.0, 0.0, 3.0);
    float3 q = sign(p) * fmod(p, c) - 0.5 * c;
    float cube = cubeSDF(q, float3(0.8, 0.8, 0.8));
    // UV
    const float2 paletteSize = float2(8,8);
    if (plane < cube) {
        float2 uv = float2(2.5,2.5) / paletteSize;
        return float4(uv, 0, plane);
    }
    float2 uv = abs(fmod(p.xz, 3.0 * paletteSize) / paletteSize / 3.0);
    return float4(uv, 0, cube);
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
float3 aproxNormal(float3 p) {
    float d = sceneSDF(p).w;
    float3 a = float3(0, EPSILON, EPSILON);
    float3 b = float3(EPSILON, 0, EPSILON);
    float3 c = float3(EPSILON, EPSILON, 0);
    return normalize(d - float3(
        sceneSDF(p + a).w,
        sceneSDF(p + b).w,
        sceneSDF(p + c).w        
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

float2 toPolarUV(float3 n)
{
    float2 pol = float2(atan2(n.x, n.z), acos(n.y));
    pol *= (1.0) / PI;
    pol.x = 0.5 * pol.x + 0.5;
    return pol;
}

Transform cameraAnimation(float time, float circleRadius)
{
    float3 position = float3(circleRadius * sin(time * 0.2), 2, circleRadius * cos(time * 0.5));
    float3 viewDir = normalize(float3(cos(time * 0.15), 0.25 * cos(time*0.18) + 0.5, sin(time * 0.25)));
    return cameraTransform(viewDir,position,float3(0,1,0));
}

constexpr sampler linearSampler(coord::normalized, filter::linear, address::clamp_to_edge);

fragment half4 main()
{
    // view position at far (z=+1) plane    
    float4 vp = float4(2 * frag.uv - 1, 1, 1.0);
    vp.y = -vp.y;
    
    float t = uni.time;
    float aspect = uni.resolution.x / uni.resolution.y;
    float fov = 90 * PI / 180;
    float4x4 invP = perspectiveInverse(fov, 0.1, 100, aspect);
    //float3 viewDir = normalize(float3(-0.5,0,1));
    //auto cam = cameraTransform(viewDir,float3(0,2,0),float3(0,1,0));
    auto cam = cameraAnimation(t, 20);
    float3 eye = cam.position.xyz;
    auto viewTr = cam.inverse();
    float4 world = invP * vp;
    world.xyz = world.xyz / world.w;
    world.xyz = viewTr * world.xyz;
    float3 ray = world.xyz - eye;
    float3 dir = normalize(ray);
    float4 d = shortestDistanceToSurface(eye, dir, MIN_DIST, MAX_DIST);
    float dist = d.w;
    float2 polar = toPolarUV(dir);
    // we have the env map in the top half
    polar.y *= 0.5; 
    float3 sky = texB.sample(linearSampler, polar).rgb;
    if (dist > MAX_DIST - EPSILON) {
        // Didn't hit anything -> sky
        float4 out = float4(sky, 1.0);
        return half4(out);
    }
    // The closest point on the surface to the eyepoint along the view ray
    float3 p = eye + dist * dir;
    float3 n = estimateNormal(p);
    float2 uvAmbient = toSampleSH(n);
    // irradiance is in the bottom half of texB
    uvAmbient = uvAmbient * 0.5 + float2(0, 0.5);
    float3 ambient = texB.sample(linearSampler, uvAmbient).rgb;
    const float3 lightDir = normalize(float3(0.5,1,-1));
    float shade = 1.5*dot(lightDir, n);
    float3 color = texA.sample(sam, d.xy).rgb;
    float4 out = float4(color * shade, 1);
    //out.rgb = n * 0.5 + 0.5;
    float occ = computeOcclusion(p, n);
    out.rgb = out.rgb * occ + 0.7 * ambient;
    float fog = exp(-0.04*dist);
    out.rgb = fog * out.rgb + (1.0 - fog) * sky;
    return half4(out);
}