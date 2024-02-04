// #genuary17 Inspired by Islamic art.
constant float PI = 3.1415926536;

float nrand(float2 uv)
{
    return fract(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

float2x2 rotationMatrix(float angle)
{
    float s=sin(angle), c=cos(angle);
    return float2x2(
        float2(c, -s),
        float2(s,  c)
    );
}

float sphereSDF(float2 p, float r, float t)
{
    float d = length(p);
    float angle = atan2(p.y, p.x);
    p.x = d * cos(angle + 0.8 * sin(2*t+3*p.x));
    p.y = 0.8 * d * sin(angle + 0.4 * sin(3*t+4*p.y+2*p.x));
    return length(p) - r;
}


float sdPolygon(float2 v[], int n, float2 p)
{
    float d = dot(p-v[0],p-v[0]);
    float s = 1.0;
    for(int i=0, j=n-1; i<n; j=i, i++)
    {
        float2 e = v[j] - v[i];
        float2 w =    p - v[i];
        float2 b = w - e*saturate(dot(w,e)/dot(e,e));
        d = min(d, dot(b,b));
        bool3 c = bool3(p.y>=v[i].y,p.y<v[j].y,e.x*w.y>e.y*w.x);
        if( all(c) || all(not(c)) ) s*=-1.0;  
    }
    return s*sqrt(d);
}

float sdStar4(float2 p, float r1, float r2, float phase)
{
    const int N = 8;
    float2 vertices[N];
    float da = 2.0 * PI / float(N);
    float dr = r1 - r2;
    for (int i = 0; i < N; i++) {
        float a = float(i) * da;
        float r = r1 - dr * (i%2);
        vertices[i] = r * float2(cos(a+phase),sin(a+phase));
    }
    return sdPolygon(vertices, N, p);
}

float ndot(float2 a, float2 b)
{
    return a.x*b.x - a.y*b.y;
}
float sdDiamond(float2 p, float2 b) 
{
    p = abs(p);
    float h = clamp( ndot(b-2.0*p,b)/dot(b,b), -1.0, 1.0 );
    float d = length( p-0.5*b*float2(1.0-h,1.0+h) );
    return d * sign( p.x*b.y + p.y*b.x - b.x*b.y );
}

float3 star8(float2 p, float r1, float r2)
{
    float d1 = sdStar4(p, r1, r2, 0);
    float d2 = sdStar4(p, r1, r2, PI / 4.0);
    float d = d1 * d2;
    d = sign(d) * sqrt(abs(d));
    float inner = (d1 < 0 && d2 < 0) ? 1 : 0;
    return saturate(float3(d,-d,inner*d));
}

float3 tiledStars(float2 p)
{
    const int N = 5;
    float2 centers[N] = {
        float2(0,0),
        float2(1,1),
        float2(-1,1),
        float2(1,-1),
        float2(-1,-1)
    };
    float3 d3 = float3(0);
    for (int i = 0; i < N; i++)
    {
        float3 d = star8(p + centers[i], 0.5, 0.15);
        if (d.y > 0) {
            d3.y = max(d3.y, d.y);
            d3.x = 0;
        } else if (d.z > 0) {
            d3.z = max(d3.z, d.z);
            d3.x = 0;
        } else if (length(d3.yz) == 0) {
            d3.x = (i == 0) ? d.x : d3.x * d.x;
        }
    }
    return d3;
}

float diamonds(float2 p)
{
    const int N = 4;
    float2 centers[N] = {
        float2(0.5, -0.5),
        float2(0.5, 0.5),
        float2(-0.5,0.5),
        float2(-0.5,-0.5)
    };
    float d_all = 1;
    for (int i = 0; i < N; i++)
    {
        float2x2 r1 = rotationMatrix(4.95*float(i)/PI + PI / 4.0);
        float d = sdDiamond(r1 * (p - centers[i]), float2(0.6, 0.18));
        if (d < 0) {
            d_all = min(d_all, d);
        } else {
            d_all *= d;
        }
    }
    if (d_all > 0) {
        d_all = sqrt(d_all);
    }
    return d_all;
}

float3 colorChoice(float4 d4)
{
    float3 blue = float3(0.03,0.12,0.47);
    float3 orange = float3(0.8, 0.4, 0);
    float3 yellow = float3(0.95,0.92,0.2);
    float3 cyan = float3(0.6,0.94,0.98);
    float3 white = float3(1,1,1);
    if (d4.w < 1.0) {
        return mix(cyan, white, d4.w);
    }
    if (d4.z > 0) {
        return mix(white, orange, d4.z);
    }
    if (d4.y > 0) {
        return mix(white, yellow, d4.y);
    }
    return mix(white, blue, d4.x);
}

fragment half4 main()
{
    float t = uni.time;
    float aspect = uni.resolution.x / uni.resolution.y;
    float zoom = 1.5*sin(0.5*t+0.25*frag.uv.x) + 2.0;
    float2x2 rot = rotationMatrix(cos(0.5*t+0.3*frag.uv.y));
    float2 uv = fract(rot * zoom * frag.uv) * 2 - 1;
    uv.x *= aspect;
    float3 d3 = tiledStars(uv);
    float d = diamonds(uv);
    // I'm going to use 'd' as blend values, so adjust
    float4 d4 = float4(d3, d);
    if (d > 0) {
        d4.x *= sqrt(d);
        d4.w = 1.0;
    } else {
        d4.w = 0.08/sqrt(saturate(-d));
        d4.x = 0;
    }
    d4.xyz = pow(d4.xyz,float3(0.05,0.15,0.2));
    float4 out = float4(colorChoice(d4), 1.0);
    //out = d4;
    return half4(out);
}