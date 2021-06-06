%% Load tif
clear;
clc;
filename='DEMs/portugal_wgs84.tif';
load coastlines;
[A,R] = readgeoraster(filename);


%% Get input from the user
%figure();
%worldmap('portugal');
%plotm(coastlat,coastlon)
%[LAT,LON]=inputm(1);  %#ok<*ASGLU>

%% Or use the uavision dataset coordinates
%LAT=39.82026;
%LON=-8.54395;

%% moinhos
% LAT=39.0342981;
% LON=-9.2182466;

%% torres
LAT=39.029006;
LON=-9.222142;

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

% make X and Y vectors for scale 
window=60;%in cells
small_A=A(A_lat-window:A_lat+window,A_lon-window:A_lon+window);
res=30;
DEM_X=res*size(small_A,1)/-2:res:res*size(small_A,1)/2; DEM_X=DEM_X(1:size(small_A,1));
DEM_Y=res*size(small_A,2)/-2:res:res*size(small_A,2)/2; DEM_Y=DEM_Y(1:size(small_A,2));


% Show map around point
figure();
surf(DEM_X,DEM_Y,small_A);
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
%% save croped DEM as a matrix
% str=strcat(int2str(LAT*1e4),'_',int2str(LON*1e4),'.mat');
% save(str,'small_A');
