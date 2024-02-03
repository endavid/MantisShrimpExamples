// #genuary16 Draw 10,000 of something.
// Falling curved rain with mesh shaders.

using TriangleMeshType = metal::mesh<VertexOut, PrimOut, MaxVertexCount, MaxPrimitiveCount, topology::line>;

float nrand(float2 uv)
{
    return fract(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

void objectStage()
{
    const uint32_t gridWidth = uni.gridSize.x;
    const uint32_t gridHeight = uni.gridSize.y;
    const uint32_t meshWidth = uni.gridSize.z;
    const uint32_t meshHeight = uni.gridSize.w;
    const uint32_t width = meshWidth * gridWidth;
    const uint32_t height = meshHeight * gridHeight;
    const uint32_t numLinesPerObject = meshWidth * meshHeight;

    payload.vertexCount = numLinesPerObject;
    payload.primitiveCount = numLinesPerObject;
    
    float scaleX = 1.0 / float(width);
    float scaleY = 1.0 / float(height);
    payload.size = float2(scaleX, scaleY);
    uint oi = positionInGrid.x;
    uint oj = positionInGrid.y;
    
    float2 objCenter = float2((2.0 * oi - gridWidth + 1.0)/float(gridWidth),
                              (2.0 * oj - gridHeight + 1.0)/float(gridHeight));
    
    float2 texel = (objCenter + 1.0) * 0.5;
    texel.y = 1.0 - texel.y;
    payload.uv = texel;
    
    float velocity = uni.scale * 0.1;
    float t = uni.time;
    float dt = 1.0 / velocity;

    for (uint mj = 0; mj < meshHeight; mj++)
    {
        for (uint mi = 0; mi < meshWidth; mi++)
        {
            uint quadIndex = mj * meshWidth + mi;
            float2 offset = float2((2.0 * mi - meshWidth + 1.0)/float(width),
                                   (2.0 * mj - meshHeight + 1.0)/float(height));
            float2 p = objCenter + offset;
            float2 uv = (p + 1.0) * 0.5;
            float v = (0.5 * nrand(uv) + 0.5) * velocity;
            uv.y = 1.0 - uv.y;
            float x = nrand(uv) * 2.0 - 1.0;
            float y = fract(nrand(texel+uv) - v * t) * 2.1 - 1.05;
            payload.vertices[quadIndex].position = float4(x, y, 0, 1);
            payload.vertices[quadIndex].normal = float4(0,0,1,1);
            payload.vertices[quadIndex].uv = uv;
        }
    }
    // identity matrix
    payload.transform = float4x4(float4(1, 0, 0, 0),
                                 float4(0, 1, 0, 0),
                                 float4(0, 0, 1, 0),
                                 float4(0, 0, 0, 1));
    // Set the output submesh count for the mesh shader.
    // Because the mesh shader is only producing one mesh, the threadgroup grid size is 1 x 1 x 1.
    props.set_threadgroups_per_grid(uint3(1, 1, 1));
}

void meshStage()
{
    // tid = 0 always, because there's only one thread per mesh
    // lid = 0..<n ; n lines per mesh
    if (tid == 0)
    {
        // number of lines
        output.set_primitive_count(payload.primitiveCount);
    }
    // transform all vertex data.
    if (lid < payload.vertexCount)
    {
        float length = 0.05;
        float t = uni.time;
        float2 size = payload.size;
        for (uint i = 0; i < 2; i++) {
            float4 p = payload.vertices[lid].position;
            float2 s = float2(sin(t*0.2+p.y*t*0.005+p.x*t*0.002)*0.02, length);
            p.xy += s * i;
            VertexOut v;
            v.position = p;
            v.normal = payload.vertices[lid].normal.xyz;
            v.uv.xy = payload.vertices[lid].uv;
            v.uv.zw = payload.uv;
            output.set_vertex(2*lid+i, v);
        }
    }
    // Set the constant data for the entire primitive.
    if (lid < payload.primitiveCount)
    {
        PrimOut p;
        p.color = texB.sample(sam, payload.uv);
        p.color.rgb = gamma_to_linear(p.color.rgb);
        output.set_primitive(lid, p);
        // Set the output indices.
        uint i = 2*lid;
        output.set_index(i+0, i+0);
        output.set_index(i+1, i+1);
    }
}

 fragment float4 fragmentMesh()
 {
     return in.p.color;
 }