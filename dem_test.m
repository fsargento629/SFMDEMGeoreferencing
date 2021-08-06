%% load new DEM
%filename='DEMs/eu_dem_v11_E20N10.TIF';
filename='DEMs/portugal_wgs84.tif';
[A,R] = readgeoraster(filename);
%% geo to intrisinsic
lat=41.2870;
lon=-7.2417;
[xIntrinsic,yIntrinsic] = geographicToIntrinsic(R,lat,lon)

%% crop
latlim=[41.2861,41.325];
lonlim=[-7.246,-7.2214];
[B,RB] = geocrop(A,R,latlim,lonlim);
% show cropped area
worldmap(latlim,lonlim)
geoshow(B,RB,'DisplayType','surface')
demcmap(B)
%% determine res
A_00=[RB.LatitudeLimits(1),RB.LongitudeLimits(1),0];
% x
[x,~] = latlon2local(RB.LatitudeLimits(1),RB.LongitudeLimits(2),0,A_00);
% y
[~,y] = latlon2local(RB.LatitudeLimits(2),RB.LongitudeLimits(1),0,A_00);


x_res=x/RB.RasterSize(2)
y_res=y/RB.RasterSize(1)
R=RB;A=B;
%% show map
[c_origin,l_origin] = geographicToIntrinsic(R,origin(1),origin(2));
X= ((1:R.RasterSize(2))-c_origin )* x_res; % WEST-EAST
Y=( (-1:-1:-R.RasterSize(1)) + l_origin )*y_res; % NORTH-SOUTH
figure;
surf(X,Y,A);
ylabel("Y North"); xlabel("X east");
axis equal;