%% load simulation results
close all; load('A_0_2_40_KAZE_EIGEN_P7');
%% load DEM
if exist('A','var') == 0
    load("DEMs/portugal_DEM"); 
end
LAT=gps(1,1); LON=gps(1,2); 
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
x0=round(X(1)/30); xf=round(X(end)/30);
y0=round(Y(1)/30); yf=round(Y(end)/30);

DEM_X=X(1):30:X(end);
DEM_Y=Y(1):30:Y(end);
DEM_Z=A(A_lon+y0:A_lon+yf,A_lat+x0:A_lat+xf);

%% Create larger DEM for ICP
window=60;
small_A=A(A_lat-window:A_lat+window,A_lon-window:A_lon+window);
LARGE_X=30*size(small_A,1)/-2:30:30*size(small_A,1)/2-1; 
LARGE_Y=30*size(small_A,2)/-2:30:30*size(small_A,2)/2-1; 

%% show real DEM
figure; surf(DEM_X,DEM_Y,DEM_Z);
title("Real DEM"); 
xlabel("X East [m]");ylabel("Y North [m]"); zlabel("Z altitude [m]");

%% show estimated DEM
figure; surf(X,Y,Z);
title("Recovered DEM"); 
xlabel("X East [m]");ylabel("Y North [m]"); zlabel("Z altitude [m]");

%% Show both
figure; surf(LARGE_X,LARGE_Y,small_A); hold on;
surf(X,Y,Z);
title("Real and recovered DEM"); 
xlabel("X East [m]");ylabel("Y North [m]"); zlabel("Z altitude [m]");

