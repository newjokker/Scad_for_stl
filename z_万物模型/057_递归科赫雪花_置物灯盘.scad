/* 递归科赫雪花置物灯盘 / KOCH SNOWFLAKE TRAY
   递归曲线每加一级，边数由 3*4^n 增长：这是代码生成远胜手工 CAD 的典型场景。
   depth=3 有 192 段精细边；可作为钥匙盘、LED 灯座或墙饰。全程平放打印。 */
$fn=18;
part="tray"; // [tray,wall_art,outline]
depth=3;       // 2 适合快速打印；3 为推荐的复杂度；4 很精细
size=142;
base_h=3;
wall_h=13;
line_w=3.2;

function add(a,b)=[a[0]+b[0],a[1]+b[1]];
function sub(a,b)=[a[0]-b[0],a[1]-b[1]];
function mul(a,k)=[a[0]*k,a[1]*k];
function rot60(v)=[v[0]*.5-v[1]*sqrt(3)/2,v[0]*sqrt(3)/2+v[1]*.5];
module line2d(a,b,w=line_w){ hull(){translate(a) circle(d=w);translate(b) circle(d=w);} }
module koch(a,b,n,w=line_w){
 if(n<=0) line2d(a,b,w);
 else let(v=mul(sub(b,a),1/3),p=add(a,v),q=add(p,rot60(v)),r=add(a,mul(v,2))){
  koch(a,p,n-1,w); koch(p,q,n-1,w); koch(q,r,n-1,w); koch(r,b,n-1,w);
 }
}
module snowflake(n=depth,w=line_w){
 r=size/sqrt(3);
 a=[0,2*r/3]; b=[-size/2,-r/3]; c=[size/2,-r/3];
 koch(a,b,n,w); koch(b,c,n,w); koch(c,a,n,w);
}
module tray(){
 union(){
  // 底板以初始三角形的凸包为轮廓；上面的分形壁形成复杂置物槽。
  linear_extrude(base_h) hull(){
   translate([0,size/sqrt(3)*2/3]) circle(r=4);
   translate([-size/2,-size/sqrt(3)/3]) circle(r=4);
   translate([size/2,-size/sqrt(3)/3]) circle(r=4);
  }
  translate([0,0,base_h-.08]) linear_extrude(wall_h) snowflake();
  // 内部三条递归隔断，造出 3 个浅格并强化图案的层次。
  for(a=[90,210,330]) rotate(a) translate([0,-8,base_h-.08]) linear_extrude(wall_h*.62)
   koch([0,0],[0,size*.28],max(1,depth-1),2.5);
 }
}
module wall_art(){ linear_extrude(3.2) snowflake(); }
module outline(){ snowflake(); }
if(part=="tray") tray();
else if(part=="wall_art") wall_art();
else if(part=="outline") outline();
else assert(false,"Unknown part");
