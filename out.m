jptr11=imread('zltu1.bmp');
jptr22=imread('zltu2.bmp');
lptr1=length(jptr11);
lptr2=length(jptr22);
%------------------------获取混沌序列
u=3.75;
X=0.5;
m=1;
n=1;
hd=zeros(1000,1000);
for i=1:1000*1000
      X(i+1)=X(i)*u*(1-X(i));
      if m>1000
          m=1;
          n=n+1;
      end
      hd(n,m)=X(i+1)*100;
      hd1(n,m)=fix(hd(n,m)/1);
      hd2(n,m)=uint8(hd1(n,m));
    
      m=m+1; 
end
%----------------------获取MLNCML序列
% alpha=4;
% alpha=3.9;
alpha=3.8;
yita=0.6;
epslon=0.3;
% epslon=0.4;
%%%%%%%%%%%%%%%
p=1;
q=3;
M=2;
%%%%%%%%%%%%%%%%

lattice=5;
times=256*256;
digits(14);
cs=zeros(lattice,times);
ks=cs;
cs_cml=zeros(lattice,times);
c=zeros(1,lattice);
% c(1)=0.40565487923280;
 c(1)=0.30565487923280;
  for i=2:lattice*4
     c(i)=alpha*c(i-1)*(1-c(i-1));
 end
 for i=1:lattice    
        cs(i,1)=c(i*3);
         cs_cml(i,1)=c(i*3);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%arnold %%%%%%%%%%%%%%%%%%%%%%

for n=2:times
    for i=1:lattice    
%     x=mod(((i-1)+p*(i+1)),lattice);
%     y=mod(q*(i-1)+(p*q+1)*(i+1),lattice);
 x=mod(((i)+p*(i)),lattice);
    y=mod(q*(i)+(p*q+1)*(i),lattice);
        if x==0
            x=lattice;
        end
        if y==lattice+1
            y=1;
        end
        if y==0
            y=lattice;
        end
        if x==lattice+1
            x=1;
        end
         xx=i-1;
    yy=i+1;
    if xx==0
        xx=lattice;
    end
    if yy==lattice+1
        yy=1;
    end
cs(i,n)=(1-epslon)*alpha*cs(i,n-1)*(1-cs(i,n-1)) +(1-yita)*((epslon/2)*(    alpha*cs(xx,n-1)*(1-cs(xx,n-1))   +    alpha*cs(yy,n-1)*(1-cs(yy,n-1))     ))+yita*(epslon/2)*(    alpha*cs(x,n-1)*(1-cs(x,n-1))   +    alpha*cs(y,n-1)*(1-cs(y,n-1))     );  
cs1(i,n)=fix(10*cs(i,n)/1);
cs2(i,n)=uint8(cs1(i,n));
   end
   
end
 %-------------------将置乱图片解密 
[h w]=size(jptr11);
[h w]=size(jptr22);
%置乱与复原的共同参数
n=10;
a=3;b=5;
N=h;
for i=1:n
    for y=1:h
        for x=1:w            
            xx=mod((a*b+1)*(x-1)-b*(y-1),N)+1;
            yy=mod(-a*(x-1)+(y-1),N)+1  ;        
            jptr1(yy,xx)=jptr11(y,x);
            jptr2(yy,xx)=jptr22(y,x);
        end
    end
end

%--获取MLNCML加密后的图片并与MLNCML序列进行按位异或
%---进行第一次解密
m=1;
n=1;
for i=1:lptr1*lptr1
    if n>lptr1
        m=m+1;
        n=1; 
    end
 
   ptr1(m,n)=bitxor(cs2(1,i),jptr1(m,n));
   n=n+1;
    if m>lptr1
        break;
    end
   
end
m=1;
n=1;
 for i=1:lptr2*lptr2
    if n>lptr2
        m=m+1;
        n=1; 
    end
 
   ptr2(m,n)=bitxor(cs2(2,i),jptr2(m,n));
   n=n+1;
    if m>lptr2
        break;
    end
   
 end

%---------------------------进行第二次解密
%---------提取文字长度
tlong1=0;
tlong2=0;
for i=1:16
  pixels1= dec2bin(ptr1(lptr1,i),16);
  pixels2= dec2bin(ptr2(lptr2,i),16);
  tlong1=tlong1+(pixels1(16)-48)*2^(16-i);
  tlong2=tlong2+(pixels2(16)-48)*2^(16-i);
end
%------------提取密文
m=1;
n=1;
x=1;
y=1;

for i=1:1000*16
  
    if n==17
        m=m+1;
        if m>256
            break;
        end
        n=1;
    end
    if x<=tlong1*16
  pixels= dec2bin(ptr1(m,n),16);
  mw1(m,n)=pixels(16);
  x=x+1;
    end
    if y<=tlong2*16
  pixels= dec2bin(ptr2(m,n),16);
  mw2(m,n)=pixels(16);
  y=y+1;
    end
  n=n+1;
end
mw1=uint8(mw1)-48;
mw2=uint8(mw2)-48;
%------------------------取混沌序列中的数
for i=1:1000
    gain(i,1)=hd2(1,i);
    gain1=dec2bin(gain,16);
    gain2=uint8(gain1)-48;
end
%---------------所取混沌数与文字进行按位异或得到明文
m=1;
n=1;
for i=1:1000
    for j=1:16
      if m<=tlong1*16
         mingwen1(i,j)=dec2bin(bitxor(gain2(i,j),mw1(i,j)));
          m=m+1;
      end
      if n<=tlong2*16
         mingwen2(i,j)=dec2bin(bitxor(gain2(i,j),mw2(i,j)));
         n=n+1; 
      end
    end
end 
%-----------------------将提取文字输出
txt1=bin2dec(mingwen1);%转回十进制
txt2=bin2dec(mingwen2);
txt1=char(txt1);%转换成对应的文字
txt2=char(txt2);
fprintf('%s\n',txt1)
fprintf('%s\n',txt2)