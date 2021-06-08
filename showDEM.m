function [A,R] = showDEM(lat,lon,window)
%showDEM SHow DEM of an area and return it
load("DEMs/portugal_DEM"); 
LAT=lat; LON=lon;
A_lat= floor((R.LatitudeLimits(2)-LAT)/R.CellExtentInLatitude);
A_lon= floor((LON-R.LongitudeLimits(1))/R.CellExtentInLongitude);

%% make X and Y vectors for scale 
%window=50;%in cells
small_A=A(A_lat-window:A_lat+window,A_lon-window:A_lon+window);
res=30;
DEM_X=res*size(small_A,1)/-2:res:res*size(small_A,1)/2; DEM_X=DEM_X(1:size(small_A,1));
DEM_Y=res*size(small_A,2)/-2:res:res*size(small_A,2)/2; DEM_Y=DEM_Y(1:size(small_A,2));
DEM_Y=DEM_Y(end:-1:1);

%% Show map around point
figure;
surf(DEM_X,DEM_Y,small_A); 
hold on;scatter3(0,0,small_A(51,51),100,'r');
title("DEM");
xlabel("X East [m]");
ylabel("Y North [m]");
zlabel("Z elevation [m]");

end

