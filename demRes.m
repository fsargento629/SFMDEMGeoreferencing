function [x_res,y_res] = demRes(R,origin)

step=100;
% Determine West-East  cell extent
lat=origin(1);
lon=origin(2)+step*R.CellExtentInLongitude;
[x,y]=latlon2local(lat,lon,0,[origin,0]);
x_res=x/step;

% Determine South-North  cell extent
lat=origin(1)+step*R.CellExtentInLatitude;
lon=origin(2);
[x,y]=latlon2local(lat,lon,0,[origin,0]);
y_res=y/step;

end

