// #genuary9 ASCII, using Mesh Shaders.
// Requires Mantis Shrimp v1.1
float nrand(float2 uv)
{
    return fract(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}
int nrandInt(float2 uv, float s, int maxValue)
{
    float n = s * nrand(uv);
    return int(n) % maxValue;
}
float3 nrandVGA(float2 uv)
{
    float3 palette[15] = {
        float3(170,0,0),
        float3(0,170,0),
        float3(170,85,0),
        float3(0,0,170),
        float3(170,0,170),
        float3(0,170,170),
        float3(170,170,170),
        float3(85, 85, 85),
        float3(255, 85, 85),
        float3(85, 255, 85),
        float3(255, 255, 85),
        float3(85, 85, 255),
        float3(255, 85, 255),
        float3(85, 255, 255),
        float3(255, 255, 255)
    };
    int i = nrandInt(uv, 10000.0, 15);
    return palette[i] / 255.0;
}
float sdCircle(float2 p, float r)
{
    return length(p) - r;
}
float alphaFill(float d, float width) {
    return saturate(pow(saturate(width-d)/width, 2));
}
float2x2 rotationMatrix(float angle)
{
    float s=sin(angle), c=cos(angle);
    return float2x2(
        float2(c, -s),
        float2(s,  c)
    );
}
void meshStage()
{
    if (tid == 0)
    {
        // 2 triangles per quad
        output.set_primitive_count(payload.primitiveCount * 2);
    }
    float4 color = float4(0, 0, 0, 1);
    // Setup vertices -- we apply the SDF per quad
    if (lid < payload.vertexCount)
    {
        float t = uni.time;
        float s = uni.scale + 1;
        float aspect = uni.resolution.x / uni.resolution.y;
        float2 uvQuad = payload.vertices[lid].uv; 
        float2 uv0 = 2.0 * uvQuad - 1.0;
        uv0.x *= aspect;
        float2x2 r = rotationMatrix(cos(t));
        uv0 = r * uv0;
        float2 uv = fract(2 * uv0) - 0.5;
        
        float d = sdCircle(uv, 0.2 + 0.1 * sin(t)) * exp(-length(uv0));
        d = sin(d*s + t) / s;
        int2 ij = int2(2.0 * uv0);
        color.rgb = nrandVGA(float2(ij));
        float a = alphaFill(d, 0.15);
        float2 pixelSize = uni.pixelSizeB;
        float2 charSize = float2(9,16);
        float2 charScale = charSize * pixelSize;
        int charRow = nrandInt(float2(ij), 10000, 5);
        float2 charUV = float2(round(mix(0, 5,a)) + 0.5, float(charRow) + 0.5) * charScale; 
        float2 size = payload.size;
        float2 uvCorners[4] = {
            float2(-0.5, 0.5) * charScale,
            float2(-0.5, -0.5) * charScale,
            float2(0.5, 0.5) * charScale,
            float2(0.5, -0.5) * charScale
        };
        for (uint i = 0; i < 2; i++) {
            for (uint j = 0; j < 2; j++) {
                uint k = i * 2 + j;
                float4 p = payload.vertices[lid].position;
                p.x = p.x + (2.0 * i - 1.0) * size.x;
                p.y = p.y + (2.0 * j - 1.0) * size.y;
                VertexOut v;
                v.position = p;
                v.normal = payload.vertices[lid].normal.xyz;
                v.uv.xy = charUV + uvCorners[k];
                v.uv.zw = payload.uv;
                output.set_vertex(4*lid+k, v);
            }
        }
    }
    // Set the constant data for the entire primitive.
    if (lid < payload.primitiveCount)
    {
        PrimOut p;
        p.color = color;
        output.set_primitive(2*lid, p);
        output.set_primitive(2*lid+1, p);
        // Set the output indices.
        uint i = 6*lid;
        uint k = 4*lid;
        output.set_index(i+0, k);
        output.set_index(i+1, k+2);
        output.set_index(i+2, k+1);
        output.set_index(i+3, k+1);
        output.set_index(i+4, k+2);
        output.set_index(i+5, k+3);
    }
}
fragment float4 fragmentMesh()
{
    float charMask = texB.sample(sam, in.v.uv.xy).r;
    float4 color = in.p.color * charMask;
    return color;
}