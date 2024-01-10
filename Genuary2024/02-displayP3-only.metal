// #genuary2 No palettes.
fragment half4 main()
{
    float t = uni.time;
    float blue = 0.5 + 0.5 * sin(t);
    float3 color = float3(frag.uv, blue);
    float3 c = gamma_to_linear(color);
    c = p3_to_srgb(c);
    float3 negMask = 1.0 - smoothstep(-0.001, 0.01, c);
    float3 posMask = smoothstep(0.9, 1.001, c);
    float3 mask = max(negMask, posMask);
    float p3Mask = max(mask.r, max(mask.g, mask.b));
    c = srgb_to_p3(c);
    c = linear_to_gamma(c);
    float4 out = float4(c, p3Mask);
    return half4(out);
}