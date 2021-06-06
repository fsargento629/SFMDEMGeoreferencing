function [h,A,R] = getAltitude(LAT,LON)
load("DEMs/portugal_DEM");

A_lat= floor((R.LatitudeLimits(2)-LAT)/R.CellExtentInLatitude);
A_lon= floor((LON-R.LongitudeLimits(1))/R.CellExtentInLongitude);
h=A(A_lat,A_lon);

end

