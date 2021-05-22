function [X,Y,Z] = inverseDistanceWeighting(points)
%INVERSEDISTANCEWEIGHTING Summary of this function goes here
%   Detailed explanation goes here

%% segment point cloud
p=points(points(:,3)<380,:);p=p(p(:,3)>260,:);
xwindow=[480 2490]; ywindow=[-1270 50];
% X->longitude Y-> latitude
X=xwindow(1):30:xwindow(2); Y=ywindow(1):30:ywindow(2);
L=size(X,2); % L WEST-EAST
C=size(Y,2); % C SOUTH-NORTH
%% perform IDW
tic;
pw=2;
N=size(p,1);
Z=zeros(C,L);
D=zeros(N,1);
for l=1:L
    for c=1:C
        P=[X(l),Y(c)];
        for i=1:N
            D(i)=norm(p(i,1:2)-P);
        end
        mask= D<250;
        W = 1./(D(mask).^pw);
        Z(c,l)=sum(W.*p(mask,3))/sum(W);
        disp([c,l]);
    end
end
toc;
figure();
surf(Z);

end

