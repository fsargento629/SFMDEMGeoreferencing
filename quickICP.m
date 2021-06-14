function [tform,picp,rmse,fixed] = quickICP(p,abspos,origin,gridstep)
%% load DEM
t0=tic;
fprintf("----- quickICP start ----\n\n");
fprintf("Loading Digitial Elevation Model\n");
load("DEMs/portugal_DEM");
dt=toc(t0);
fprintf("Loaded DEM in %.2f sconds\n",dt);
%% Crop DEM using a margin and the min max values of p
fprintf("Cropping Digital Elevation Model\n");
LAT=origin(1); LON=origin(2);
% get an aproximate cell for the origin, and a correction factor for the
% fixed pcl
A_lat= (R.LatitudeLimits(2)-LAT)/R.CellExtentInLatitude;
lat_correction=A_lat-floor(A_lat);
A_lat=floor(A_lat);
A_lon= (LON-R.LongitudeLimits(1))/R.CellExtentInLongitude;
lon_correction=A_lon-floor(A_lon);
A_lon=floor(A_lon);
res=30;
% window
MARGIN=20; %cells
p_abs=[p(:,1:2)+abspos(1,1:2) , p(:,3)];
x0=round(min(p_abs(:,1))/res)-MARGIN;
xf=round(max(p_abs(:,1))/res)+MARGIN;
y0=round(min(p_abs(:,2))/res)-MARGIN;
yf=round(max(p_abs(:,2))/res)+MARGIN;
% make X and Y vectors for scale

DEM_Z=A(A_lat-yf:A_lat-y0,A_lon+x0:A_lon+xf);

DEM_X=x0*res:res:xf*res; % WEST-EAST
DEM_X=DEM_X - 30*lon_correction;
DEM_Y=yf*res:-res:y0*res; % NORTH-SOUTH
DEM_Y=DEM_Y -30*lat_correction;
%% Turn DEM into pcl
fixed=zeros(size(DEM_Z,1)*size(DEM_Z,2),3);
i=1;
for l=1:size(DEM_Z,1)
    for c=1:size(DEM_Z,2)
        fixed(i,:)=[DEM_X(c), DEM_Y(l), DEM_Z(l,c)];
        i=i+1;
    end
end
fixed=pointCloud(fixed);
fprintf("DEM turned into point Cloud\n");
% %% show DEM
% figure;
% surf(DEM_X,DEM_Y,DEM_Z);
% xlabel("X East");ylabel("Y North");zlabel("Z elevation");
% title("Real DEM");
% fprintf("DEM printed\n");
%% Downsample pcl
pidw=pointCloud(p_abs);
pidw=pcdownsample(pidw,'gridAverage',gridstep);
fprintf("Point Cloud downsampled\n");

%% register the two pcls
[tform,picp,rmse]=pcregistericp(pidw,fixed,'Metric','PointToPoint',...
    'Extrapolate',false,'InlierRatio',0.01,'MaxIterations',20);
fprintf("ICP performed\n");
fprintf("RMSE from ICP: %.2f\n",rmse);
fprintf("ICP translation vector:"); disp(tform.Translation);
fprintf("----- quickICP end ----\n");
end

