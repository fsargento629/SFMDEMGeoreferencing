%% Load tif
clear;
clc;
filename='DEMs/portugal_wgs84.tif';
load coastlines;
[A,R] = readgeoraster(filename);


%% Get input from the user
figure();
worldmap('portugal');
plotm(coastlat,coastlon)
[LAT,LON]=inputm(1); 

%% Or use the uavision dataset coordinates
%LAT=38.81906;
%LON=-8.54110;

%% Determine the height of the point and show it in 2D and 3D
% Determine height for a point
A_lat= round((R.LatitudeLimits(2)-LAT)/R.CellExtentInLatitude);
A_lon= round((LON-R.LongitudeLimits(1))/R.CellExtentInLongitude);
Z=A(A_lat,A_lon);

fprintf("Terrain height at x=%f y=%f :\n %f m\n",LAT,LON,Z);

% Show point
close all;
coast = shaperead('landareas.shp','UseGeoCoords',true,'RecordNumbers',2);
figure();
worldmap(R.LatitudeLimits,R.LongitudeLimits);
hold on;
geoshow(coast);
hold on;
geoshow(LAT, LON, 'DisplayType', 'Point', 'Marker', '+', 'Color', 'red');

% Show map around point
window=20;
small_A=A(A_lat-window:A_lat+window,A_lon-window:A_lon+window);
figure();
surf(small_A);
hold on;
plot3(window+1,window+1,Z,'ro','MarkerSize',5);

%% save croped DEM as a matrix
str=strcat('DEMs',int2str(LAT*1e4),'_',int2str(LON*1e4),'.mat');
save(str,'small_A');
