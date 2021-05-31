%% load simulation results
close all; load('A_0_2_40_KAZE_EIGEN_P7');
%% load DEM
if exist('A','var') == 0
    load("DEMs/portugal_DEM"); 
end
LAT=position0(1); LON=position0(2);
A_lat= floor((R.LatitudeLimits(2)-LAT)/R.CellExtentInLatitude);
A_lon= floor((LON-R.LongitudeLimits(1))/R.CellExtentInLongitude);
h=A(A_lat,A_lon);

fprintf("Terrain height at x=%f y=%f :\n %f m\n",LAT,LON,h);

%% Show point in map
coast = shaperead('landareas.shp','UseGeoCoords',true,'RecordNumbers',2);
figure();
worldmap(R.LatitudeLimits,R.LongitudeLimits);
hold on;
geoshow(coast);
hold on;
geoshow(LAT, LON, 'DisplayType', 'Point', 'Marker', '+', 'Color', 'red');
title("Aircraft location");
%% Create smaller DEM 
% DEM window in cells from origin point
x0=floor(X(1)/30); xf=floor(X(end)/30);
y0=floor(Y(1)/30); yf=floor(Y(end)/30);

DEM_X=X(1):30:X(end);
DEM_Y=Y(1):30:Y(end);
DEM_Z=A(A_lon+y0:A_lon+yf,A_lat+x0:A_lat+xf);

%% show real DEM
figure; surf(DEM_X,DEM_Y,DEM_Z);
title("Real DEM"); 
xlabel("X East [m]");ylabel("Y North [m]"); zlabel("Z altitude [m]");

%% show estimated DEM
