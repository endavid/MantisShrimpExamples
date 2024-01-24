// #genuary10 Hexagonal, using Mesh Shaders.
// Requires Mantis Shrimp v1.1
static constexpr constant float PI = 3.1415926536;

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
float4x4 rotationY(float angle)
{
    float s=sin(angle), c=cos(angle);
    return float4x4(
        float4(c, 0, -s, 0),
        float4(0, 1, 0, 0),
        float4(s, 0, c, 0),
        float4(0, 0, 0, 1)
    );
}
float4x4 rotationX(float angle)
{
    float s=sin(angle), c=cos(angle);
    return float4x4(
        float4(1, 0, 0, 0),
        float4(0, c, -s, 0),
        float4(0, s, c, 0),
        float4(0, 0, 0, 1)
    );
}
void objectStage()
{
    const uint32_t gridWidth = uni.gridSize.x;
    const uint32_t gridHeight = uni.gridSize.y;
    const uint32_t width = gridWidth;
    const uint32_t height = gridHeight;
    const uint32_t n = width * height;

    payload.vertexCount = 1;
    payload.primitiveCount = 1;
    
    float scaleX = 1.0 / float(width);
    float scaleY = 1.0 / float(height);
    payload.size = float2(scaleX, scaleY);
    uint oi = positionInGrid.x;
    uint oj = positionInGrid.y;
    
    float2 offset = oj % 2 == 0 ? float2(0.5,3) : float2(1.5,3);
    float2 objCenter = float2((2.0 * oi - gridWidth + offset.x)/float(gridWidth),
                              (1.7 * oj - gridHeight + offset.y)/float(gridHeight));
    
    float2 texel = (objCenter + 1.0) * 0.5;
    texel.y = 1.0 - texel.y;
    payload.uv = texel;

    float2 uv = (objCenter + 1.0) * 0.5;
    uv.y = 1.0 - uv.y;
    payload.vertices[0].position = float4(0,0,0,1);
    payload.vertices[0].normal = float4(0,0,1,1);
    payload.vertices[0].uv = uv;
    // for animation
    float step = 500 * uni.time / float(n);
    int currentObj = int(step) % n;
    float angle = 2.0 * PI * fract(step);
    // zig-zag ascending order
    int order = gridWidth * oj + ((oj % 2 == 0) ? oi : gridWidth - 1 - oi);
    int orderReverse = n - 1 - order;
    // transform
    float aspect = uni.resolution.x / uni.resolution.y;
    float4x4 projection = perspective(0.1, 0.01, 50, aspect);
    float4x4 view = rotationY(0);
    int repeat = 17;
    currentObj = currentObj % repeat;
    order = order % repeat;
    orderReverse = orderReverse % repeat;
    float phaseY = currentObj == order ? angle : 0;
    float phaseX = currentObj == orderReverse ? angle : 0;
    float4x4 modelTr = rotationX(-PI/3.8 + phaseX) * rotationY(-PI/4 + phaseY);
    modelTr[3] = float4(objCenter, -20, 1);
    payload.transform = projection * view * modelTr;
    // Set the output submesh count for the mesh shader.
    // Because the mesh shader is only producing one mesh, the threadgroup grid size is 1 x 1 x 1.
    props.set_threadgroups_per_grid(uint3(1, 1, 1));
}

void meshStage()
{
    // tid = 0 always, because there's only one thread per mesh
    // lid = 0..<n ; n triangles per mesh
    if (tid == 0)
    {
        // 6 faces x 2 triangles
        output.set_primitive_count(payload.primitiveCount * 12);
    }
    // Create cube vertices centered around the object position
    if (lid < payload.vertexCount)
    {
        float2 size = 1.4 * payload.size / uni.scale;
        float sizez = max(size.x, size.y);
        for (uint k = 0; k < 2; k++) {
          for (uint i = 0; i < 2; i++) {
            for (uint j = 0; j < 2; j++) {
                uint index = k * 4 + i * 2 + j;
                float4 p = payload.vertices[lid].position;
                p.x = p.x + (2.0 * i - 1.0) * size.x;
                p.y = p.y + (2.0 * j - 1.0) * size.y;
                // right-handed, +Z is front
                p.z = p.z + (-2.0 * k + 1.0) * sizez;
                VertexOut v;
                p = payload.transform * p;
                v.position = p;
                v.normal = payload.vertices[lid].normal.xyz;
                v.uv.xy = payload.vertices[lid].uv;
                v.uv.zw = payload.uv;
                output.set_vertex(8*lid+index, v);
            }
          }
        }
    }
    // Set the constant data for the entire primitive.
    if (lid < payload.primitiveCount)
    {
        int faces[36] = {
            // front
            3, 1, 0, 0, 2, 3,
            // right
            7, 3, 2, 2, 6, 7,
            // left
            1, 5, 4, 4, 0, 1,
            // up
            7, 5, 1, 1, 3, 7,
            // down
            2, 0, 4, 4, 6, 2,
            // back
            5, 7, 6, 6, 4, 5
        };
        float3 colors[6] = {
            float3(151,224,255), // front
            float3(0,111,174), // right
            float3(243,249,131), // left
            float3(0,161,255), // up
            float3(92,50,11), // down           
            float3(249,186,0) // back
        };
        uint k = 8 * lid;
        for (uint face = 0; face < 6; face++)
        {
          PrimOut p;
          p.color = float4(colors[face]/255.0, 1.0);
          output.set_primitive(12*lid+2*face, p);
          output.set_primitive(12*lid+2*face+1, p);
          // Set the output indices.
          uint i = 36*lid;
          for (uint j = 0; j < 6; j++)
          {
              uint v = 6 * face + j;
              output.set_index(i+v, k+faces[v]);
          }
        }
    }
}

fragment float4 fragmentMesh()
{
    return in.p.color;
}