// #genuary14 1K
#define f float
#define f2 float2
f sdf(f2 p,f r,f t){
 f d=length(p);
 f a=atan2(p.y,p.x);
 p.x=d*cos(a+0.8*sin(2*t+3*p.x));
 p.y=0.8*d*sin(a+0.4*sin(3*t+4*p.y+2*p.x));
 return length(p)-r;
}
fragment half4 main()
{
 f t=uni.time;
 f2 u=frag.uv*2-1;
 f d=sdf(u,0.5,t);
 return half4(0.1*fmod(d,0.25),-d,0.2*fmod(d,0.5),1.0);
}