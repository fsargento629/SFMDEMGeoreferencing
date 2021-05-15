%% load results
close all;
clear;
%load('SFM_results/results_11-05-2021 17-07');
%% plot keypoints
close all;

window_x=[0,1000];
window_y=[-1000,500];
window_z=[-1100,-220];
X=xyzPoints(:,1);
Y=xyzPoints(:,2);
Z=xyzPoints(:,3);  

figure;
mask= abs(Z)<5000;
plot3(X(mask),Y(mask),Z(mask),'ro','MarkerSize',5);
hold on;
plotCamera(camPoses(1,:), 'Size', 100,'Color','k');
hold on;
%surf(-1000:200:1000,-1000:200:1000,camera_z*ones(11,11));
xlabel('X (m) [East]');
ylabel('Y (m) [Norh]');
zlabel('Z (m) [Down]');
xlim(window_x);
ylim(window_y);
zlim(window_z);

%load and plot DEM
load('DEMs/uavision_DEM_large');
res=30;%m/square
DEM_X=res*size(small_A,1)/-2:res:res*size(small_A,1)/2; DEM_X=DEM_X(1:size(small_A,1));
DEM_Y=res*size(small_A,2)/-2:res:res*size(small_A,2)/2; DEM_Y=DEM_Y(1:size(small_A,2));
hold on;
surf(DEM_X,DEM_Y,-small_A);

% plot target
lat_t=39.841935;lon_t=-8.509407;
[x_t ,y_t]=latlon2local(lat_t,lon_t,250,[gps(1,:) altitude(1)]);
plot3(x_t,y_t,-250,'g*');
set(gca, 'ZDir','reverse')
%% plot height as a function of XY distance
figure;
D=sqrt(X.^2+Y.^2);
mask=D<2000;
plot(D(mask),Z(mask),'o');
hold on;
yline(-cam_z(1));
hold on;
yline(-mean(small_A,'all'));
xlabel('XY Distance from camera');
ylabel('Estimated height');

%% plot XY coordinates of points
figure();
scatter(X(mask),Y(mask));   
hold on;
viscircles([0,0],100);


%% plot estimated camera trajectory
camera_traj=zeros(size(camPoses,1),3);
for i=1:size(camPoses,1)
    camera_traj(i,:)=camPoses.AbsolutePose(i,1).Translation;
end
figure();
plot3(camera_traj(:,1),camera_traj(:,2),camera_traj(:,3),'k*--');

%% Estimated camera orientation
orientation=zeros(size(camPoses,1),3);
for i=1:size(camPoses,1)
    orientation(i,:)=rad2deg(rotm2eul(camPoses(i,2).AbsolutePose.Rotation,'XYZ'));
end
figure;plot(orientation(:,1));title('Camera Roll');
figure;plot(orientation(:,2));title('Camera Pitch');
figure;plot(orientation(:,3)); title('Camera Heading');

%% plot real camera trajectory
figure();
plot3(cam_x,cam_y,cam_z,'k--o');
title("Real trajectory");
xlabel("East");
ylabel("North");
%% Debugging
% Visualize  features
figure;imshow(I);hold on;scatter(prevPoints.Location(:,1),prevPoints.Location(:,2));
% store pixel values of tracks (on the 2nd image)
pixels=zeros(size(tracks,2),2);
for i=1:size(tracks,2)
    pixels(i,:)=tracks(i).Points(2,:);
end

% Visualize matched pixels
figure;
imshow(I);hold on;scatter(pixels(:,1),pixels(:,2),'r*');

%% Check triangulate multiview traiangulation
xyz_est=triangulateMultiview(tracks, camPoses, intrinsics);
D_est=sqrt(xyz_est(:,1).^2+xyz_est(:,2).^2);

% Plot triangulated points in 3D with cameras
figure;plot3(xyz_est(:,1),xyz_est(:,2),xyz_est(:,3),'o');
hold on; plotCamera(camPoses, 'Size', 20,'Color','k');

% view in 2D
figure; plot(xyz_est(:,1),xyz_est(:,2),'ko');
% Reprojection error Histogram analysis
figure;histogram(reprojectionErrors);title('Reprojection Error');
% Point height with distance
figure;plot(D_est,xyz_est(:,3),'ko'); title('Point height'); 

% 3D plot with reprojection erros
scatter3(xyz_est(:,1),xyz_est(:,2),xyz_est(:,3),reprojectionErrors);
%% check outliers
% change bad_mask to see different types of outliers
D_est=sqrt(xyz_est(:,1).^2+xyz_est(:,2).^2);
bad_mask= xyz_est(:,1)<0 | xyz_est(:,2)<0 ; 

pixels=zeros(size(tracks,2),2);
for i=1:size(tracks,2)
    pixels(i,:)=tracks(i).Points(2,:);
end
bad_pixels=pixels(bad_mask,:);
figure;imshow(I);hold on;scatter(bad_pixels(:,1),bad_pixels(:,2),reprojectionErrors(bad_mask));

%% Analyze trajectory and target coordinates for t=2min33s
% t=2min33s
lat_1=39.84535; lon_1=-8.53602; alt_1=3048*0.3048;
% t=2min43s
lat_2=39.84438; lon_2=-8.52965; alt_2=3023*0.3048;
% target coordinates
lat_t=39.830191; lon_t= -8.532698; alt_t=250;

% pass them to cartesian 
z=[alt_1 alt_2];
x=zeros(2,1);y=zeros(2,1);
[x(2),y(2)]=latlon2local(lat_2,lon_2,alt_2,[lat_1 lon_1 alt_1]); %x east y nort
[x_t,y_t]=latlon2local(lat_t,lon_t,alt_t,[lat_1 lon_1 alt_1]);
figure;plot3(x,y,z,'k--o');
hold on;plot3(x_t,y_t,alt_t,'r*');
xlabel("X east");
ylabel("Y North");
figure;
plot(x,y,'k--o');
hold on;plot(x_t,y_t,'r*');
xlabel("X east");
ylabel("Y North");
plane_heading=rad2deg(atan2(x(2),y(2)))

%% Analyze trajectory and target coordinates for t=30s
% t=30s
lat_1=39.8272; lon_1=-8.5506; alt_1=945;
% t=35s
lat_2=39.8275; lon_2=-8.5508; alt_2=946;
% target coordinates
lat_t=39.841935;lon_t=-8.509407;; alt_t=250;

% pass them to cartesian 
z=[alt_1 alt_2];
x=zeros(2,1);y=zeros(2,1);
[x(2),y(2)]=latlon2local(lat_2,lon_2,alt_2,[lat_1 lon_1 alt_1]); %x east y nort
[x_t,y_t]=latlon2local(lat_t,lon_t,alt_t,[lat_1 lon_1 alt_1]);
figure;plot3(x,y,z,'k--o');
hold on;plot3(x_t,y_t,alt_t,'r*');
xlabel("X east");
ylabel("Y North");
figure;
plot(x,y,'k--o');
hold on;plot(x_t,y_t,'r*');
xlabel("X east");
ylabel("Y North");
plane_heading=rad2deg(atan2(x(2),y(2)))