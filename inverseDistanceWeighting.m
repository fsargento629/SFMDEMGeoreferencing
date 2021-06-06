function [X,Y,Z,p] = inverseDistanceWeighting(points)
%INVERSEDISTANCEWEIGHTING Summary of this function goes here
%   Detailed explanation goes here
res=30;
%% segment point cloud
%p=points(points(:,3)<380,:);p=p(p(:,3)>260,:);
p=points;
p=p(p(:,3)<260 & p(:,3)>180,:);
%% define window
xwindow=[round(min(p(:,1))), round(max(p(:,1)))];
ywindow=[round(min(p(:,2))), round(max(p(:,2)))];
% Y-> (N-S) X->  (W-E)
X=xwindow(1):res:xwindow(2); Y=ywindow(1):res:ywindow(2);
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
h = waitbar(0,'Performing IDW');
for l=1:L
    for c=1:C
        P=[X(c),Y(l)];
        for i=1:N
            D(i)=norm(p(i,1:2)-P);
        end
        mask= D<400;
        W = 1./(D(mask).^pw);
        Z(l,c)=sum(W.*p(mask,3))/sum(W);
        %disp([l,c]);
    end
    waitbar(l/L,h);
end
close(h);
toc;


%% remove disconnected lines
% trim Z from the left
for c=round(size(Z,2)/2):-1:1
    a=isnan(Z(:,c));
    if sum(~a)==0
        Z=Z(:,c+1:end);
        X=X(:,c+1:end);  
        break;
    end
end
% trim Z from the middle to the right
for c=round(size(Z,2)/2):size(Z,2)
    a=isnan(Z(:,c));
    if sum(~a)==0
        Z=Z(:,1:c-1);
        X=X(:,1:c-1);
        break;
    end
end




% plot only height map
figure();
surf(Z);

% plot height map and point cloud
figure;surf(X,Y,Z);hold on;
scatter3(p(:,1),p(:,2),p(:,3),'r');
xlabel('X East (m)');ylabel('Y North (m)');zlabel('Z Elevation  (m)');
title("Recovered DEM and recovered feature points");
legend("Recovered DEM","Recovered feature points");

end

