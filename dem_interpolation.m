%% load dem
load('DEMs\vila_real_DEM.mat');
origin=[41.3103,-7.3755];
%% turn A into a point cloud
% make X and Y vectors
[c_origin,l_origin] = geographicToIntrinsic(R,origin(1),origin(2));
X= ((1:R.RasterSize(2))-c_origin )* x_res; % WEST-EAST
Y=( (-1:-1:-R.RasterSize(1)) + l_origin )*y_res; % NORTH-SOUTH
% convert matrix to pcl
C=size(X,2); L=size(Y,2);
XYZ=zeros(C*L,3);
i=1;
for l=1:L
    for c=1:C
        XYZ(i,:)=[X(c),Y(l),A(l,c)];
        i=i+1;
    end
end

DEM=pointCloud(XYZ);
%% interpolate
F1 = scatteredInterpolant(XYZ(:,1),XYZ(:,2),XYZ(:,3));
[xq,yq] = ndgrid(-1500:10:3000,-2400:10:3800);
figure;
vq1 = F1(xq,yq);
surf(xq,yq,vq1);
%% turn matrices into pcl
N=numel(vq1);
XYZ=zeros(N,3);
XYZ(:,1)=reshape(xq,1,[]);
XYZ(:,2)=reshape(yq,1,[]);
XYZ(:,3)=reshape(vq1,1,[]);
DEM_interpol=pointCloud(XYZ);