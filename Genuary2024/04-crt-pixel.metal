// #genuary4 Pixel
float sdCircle(float2 p, float r)
{
    return length(p) - r;
}
float4 fill(float d, float width, float4 color) {
    if (-d > width) {
        return color;
    }
    float a = saturate(-d/width + 1);
    return color * a;
}
float4 drawScene(float2 uv, texture2d<float> tex, sampler sam) {
    float4 rgb[] = {
        float4(1.0, 0.0, 0.0, 1.0),
        float4(0.0, 1.0, 0.0, 1.0),
        float4(0.0, 0.0, 1.0, 1.0)
    };
    float4 out = float4(0, 0, 0, 1.0);
    float4 c = out;
    int w = 32;
    int w3 = w * 3;
    float dotSize = 0.32 / w3;
    for (int i = 0; i < w3; i++) {
      float y = (i + 0.5) / w3;
      float offsetX = (i % 2) * 1.5 - 1.0;
      int iTex = i / 3;
      float v = float(iTex) / float(w);
      for (int j = 0; j < w3 + 2; j++) {
        float x = (j + offsetX) / w3;
        int jTex = j / 3;
        float u = float(jTex) / float(w);
        float4 color = tex.sample(sam, float2(u,v));
        float4 mask = rgb[j % 3];
        float4 cell = color * mask;
        c = fill(sdCircle(uv - float2(x, y), dotSize), dotSize * 0.85, cell);
        out.rgb += c.rgb;
      }
    }
    return out;
}
fragment half4 main()
{
    float aspect = uni.resolution.x / uni.resolution.y;
    float2 uv = frag.uv;
    uv.x *= aspect;
    float2 offsetOut = float2(0.5,0.5)*(1-uni.scale);
    float2 zoomedOut = uni.scale * uv + offsetOut;
    float scaleIn = 0.25;
    float2 offsetIn = float2(0.7,0.7)-scaleIn*float2(0.5, 0.5);
    float2 zoomedIn = uv*scaleIn + offsetIn;
    float t = pow(sin(uni.time) * 0.5 + 0.5, 4);
    uv = mix(zoomedIn, zoomedOut, t);
    float4 out = drawScene(uv, texB, sam);
    return half4(out);
}