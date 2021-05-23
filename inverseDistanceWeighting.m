function [X,Y,Z,p] = inverseDistanceWeighting(points)
%INVERSEDISTANCEWEIGHTING Summary of this function goes here
%   Detailed explanation goes here

%% segment point cloud
p=points(points(:,3)<380,:);p=p(p(:,3)>260,:);
xwindow=[480 2490]; ywindow=[-1270 50];
% Y-> (N-S) X->  (W-E)
X=xwindow(1):30:xwindow(2); Y=ywindow(1):30:ywindow(2);
L=size(Y,2); % L SOUTH-NORTH
C=size(X,2); % C WEST-EAST
%% perform IDW
tic;
pw=2; % weight power
N=size(p,1);
Z=zeros(L,C);
D=zeros(N,1);
% lines-> South North (Y) 
% columns -> West East (X)
for l=1:L
    for c=1:C
        P=[X(c),Y(l)];
        for i=1:N
            D(i)=norm(p(i,1:2)-P);
        end
        mask= D<100;
        W = 1./(D(mask).^pw);
        Z(l,c)=sum(W.*p(mask,3))/sum(W);
        disp([l,c]);
    end
end
toc;
figure();
surf(Z);

end

