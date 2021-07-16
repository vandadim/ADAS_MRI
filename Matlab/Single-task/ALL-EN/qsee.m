function [qr,qz]=qsee(a,b,c)
z=a+b
if ~exist('c','var')
    c = 5;
end
qr=a+b+z+c
qz=a+b+z

end
