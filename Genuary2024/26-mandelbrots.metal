// #Genuary26 Grow a seed
// These are 3 Mandelbrot sets layered on top of each other

constant float PI = 3.1415926536;

float mandelbrot(float2 c, float2 seed, int iterations)
{
    float2 z = seed;
    int iteration = 0;
    while (dot(z, z) < 4.0 && iteration < iterations) {
        float x = z.x * z.x - z.y * z.y + c.x;
        float y = 2.0 * z.x * z.y + c.y;
        z = float2(x, y);
        iteration++;
    }
    return float(iteration)/float(iterations);
}


fragment half4 main()
{
    float t = uni.time;
    float aspect = uni.resolution.x / uni.resolution.y;
    float2 uv = frag.uv * 2 - 1;
    uv.x -= 0.5;
    uv.x *= aspect;
    
    // zoom UVs
    float4 aabb = float4(0.37, -0.6, 0.38, -0.56);
    float2 size = aabb.zw - aabb.xy;
    float2 center = size / 2 + aabb.xy;
    float2 offset = center - size.y*float2(0.5, 0.5);
    float2 zoomed = size.y*uv + offset;
    constexpr float cycleSecs = 10; // time to loop
    float a = 0.5*sin(t * 2 * PI / cycleSecs)+0.5;
    uv = mix(uv, zoomed, pow(a,0.5));
    
    // fractal
    float2 seed = float2(0.25*sin(t), 0.4*cos(t));
    float d1 = mandelbrot(1.5*uv, seed, 50); // inner
    float d2 = mandelbrot(1.15*uv, seed, 50);
    float d3 = mandelbrot(0.95*uv, seed, 50); // outer
    
    // color
    float3 c1 = float3(d1*0.8, d1 * 0.225, d1 * 0.0125);
    float3 c2 = float3(d2*0.1, 0.7*d2, d2*0.01);
    float3 c3 = float3(d3*0.5, d3*0.25, d3*0.125);
    float3 color = mix(c1, mix(c2, c3, 1-d2), 1-d1);
    float4 out = float4(color, 1.0);    
    return half4(out);
}