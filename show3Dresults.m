function [A,R] = show3Dresults(A,R,p,traj,gps,heading,pitch)
%SHOW3DRESULTS Summary of this function goes here
%   Detailed explanation goes here

%% Select a relevant window
% LAT=gps(1,1); LON=gps(1,2);
% A_lat= round((R.LatitudeLimits(2)-LAT)/R.CellExtentInLatitude);
% A_lon= round((LON-R.LongitudeLimits(1))/R.CellExtentInLongitude);
% Z=A(A_lat,A_lon);
 traj(:,3)=-traj(:,3);
% fprintf("Terrain height at x=%f y=%f :\n %f m\n",LAT,LON,Z);
% 
% %% Show point in map
% coast = shaperead('landareas.shp','UseGeoCoords',true,'RecordNumbers',2);
% figure();
% worldmap(R.LatitudeLimits,R.LongitudeLimits);
% hold on;
% geoshow(coast);
% hold on;
% geoshow(LAT, LON, 'DisplayType', 'Point', 'Marker', '+', 'Color', 'red');
% title("Aircraft location");
% %% Create smaller DEM 
% window=120;%in cells
% small_A=A(A_lat-window:A_lat+window,A_lon-window:A_lon+window);
% res=30;
% DEM_X=res*size(small_A,1)/-2:res:res*size(small_A,1)/2; DEM_X=DEM_X(1:size(small_A,1));
% DEM_Y=res*size(small_A,2)/-2:res:res*size(small_A,2)/2; DEM_Y=DEM_Y(1:size(small_A,2));

%% show DEM, points and trajectory
% Show map around point
figure();
%surf(DEM_X,DEM_Y,small_A); hold on;

% show points
scatter3(p(:,1),p(:,2),p(:,3),1,'ro');hold on;

% show trajectory
plot3(traj(:,1),traj(:,2),traj(:,3),'go--');

% make figure look better
xlabel('X East (m)');
ylabel('Y North (m)');
zlabel('Z height from sea level (m)');
title("3D reconstruction");

%% show cameras
vSet = imageviewset;
for i=1:size(heading,1)
    yaw=deg2rad(-heading-90);
    roll=zeros(size(pitch));
    pitch2=deg2rad(90+pitch+180);
    vSet = addView(vSet, i, ... 
        rigid3d(angle2dcm( yaw(i), pitch2(i), roll(i),'ZYZ'),traj(i,:)));
end
camPoses=poses(vSet);
plotCamera(camPoses, 'Size', 50,'Color','k');


%% show only the poitn cloud
figure;scatter3(p(:,1),p(:,2),p(:,3),1,'ro');
xlabel('X East (m)');
ylabel('Y North (m)');
zlabel('Z height from sea level (m)');
title("Recovered point cloud");
