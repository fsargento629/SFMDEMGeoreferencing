function h = heightAtDistance(gps,d)
%heightAtDistance Return the terrain height

load("DEMs/portugal_DEM"); 

LAT=gps(1); LON=gps(2);
cell_d=round([d(2)/30,d(1)/30]);
A_lat= floor((R.LatitudeLimits(2)-LAT)/R.CellExtentInLatitude);
A_lon= floor((LON-R.LongitudeLimits(1))/R.CellExtentInLongitude);
h=A(A_lat+cell_d(1),A_lon+cell_d(2));

end

