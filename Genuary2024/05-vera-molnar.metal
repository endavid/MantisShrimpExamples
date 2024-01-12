// #genuary5 Vera Molnar
float nrand(float2 uv)
{
    return fract(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}
float nrandNeg(float2 uv)
{
    return nrand(uv) - 0.5;
}
float sdSegment(float2 p, float2 a, float2 b)
{
    float2 pa = p-a, ba = b-a;
    float h = saturate(dot(pa,ba)/dot(ba,ba));
    return length( pa - ba*h );
}
float sdQuad(float2 p, float4 ab, float4 cd)
{
    float d1 = min(sdSegment(p, ab.xy, ab.zw), sdSegment(p, ab.zw, cd.xy));
    float d2 = min(sdSegment(p, ab.xy, cd.zw), sdSegment(p, cd.zw, cd.xy));
    return min(d1, d2);
}
float4 colorLine(float d, float width, float4 color) {
    float a = pow(saturate(width-abs(d))/width, 2);
    return a * color;
}
fragment half4 main()
{
    float4 white = float4(243, 238, 235, 255) / 255;
    float4 black = float4(20, 8, 6, 255) / 255;
    float t = 2 * uni.time;
    float aspect = uni.resolution.x / uni.resolution.y;
    float2 uv = frag.uv;
    uv.x *= aspect;
    float d = 1;
    float size = 1/uni.scale;
    float bigSq = 0.8 * size;
    float smallSq = 0.5 * size;
    float tinySq = 0.2 * size;
    for (float x = -0.5*size; x < 1; x+=size) {
      for (float y = 0.4 * size; y < 1; y+=size) {
          float4 ab = float4(x,y,x+bigSq,y);
          float4 cd = float4(x+bigSq,y+bigSq,x,y+bigSq);
          if (nrand(ab.xy) < 0.8) {
              ab.x += nrandNeg(ab.xz) * 0.2 * bigSq * sin(t+nrand(ab.xy));
              ab.y += cos(t) * 0.2 * bigSq;
              cd.w += sin(t + nrand(cd.wz)) * 0.2 * bigSq;
              cd.y += nrandNeg(cd.xy) * 0.2 * bigSq * sin(t);
              float d1 = sdQuad(uv, ab, cd);
              d = min(d, d1);
          }
          float x0 = x + 0.6*size;
          float y0 = y - 0.4*size;
          ab = float4(x0,y0,x0+smallSq,y0);
          cd = float4(x0+smallSq,y0+smallSq,x0,y0+smallSq);
          if (nrand(ab.xy) < 0.8) {
              ab.y += nrandNeg(ab.xz) * 0.2 * smallSq * sin(t+nrand(ab.xy));
              cd.x += nrandNeg(cd.xy) * 0.2 * smallSq * cos(t);
              float d1 = sdQuad(uv, ab, cd);
              d = min(d, d1);
          }
          x0 = x + 0.3*size;
          y0 = y + 0.3*size;
          ab = float4(x0,y0,x0+tinySq,y0);
          cd = float4(x0+tinySq,y0+tinySq,x0,y0+tinySq);
          if (nrand(float2(x0,y0)) < 0.5) {
              ab.x += nrandNeg(ab.zw) * 0.3 * tinySq;
              ab.y += nrandNeg(ab.xz) * 0.25 * tinySq * cos(t);
              cd.x += nrandNeg(cd.xy) * 0.2 * tinySq;
              cd.w += sin(t) * 0.2 * tinySq;
              float d1 = sdQuad(uv, ab, cd);
              d = min(d, d1);
          }
      }
    }
    float4 lines = colorLine(d, 0.01, black);
    float4 out = float4(0,0,0,1.0);
    out.rgb = mix(white.rgb, lines.rgb, lines.a);
    return half4(out);
}