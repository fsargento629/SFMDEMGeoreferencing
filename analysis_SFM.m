%% load results
close all;
clear;
%load('SFM_results/results_11-05-2021 17-07');
%% plot keypoints
close all;

window_x=[0,1000];
window_y=[-1000,100];

X=xyzPoints(:,1);
Y=xyzPoints(:,2);
Z=xyzPoints(:,3);

figure;
mask= Z>-1.5e3;
plot3(X(mask),Y(mask),Z(mask),'ro','MarkerSize',5);
hold on;
plotCamera(camPoses(:,:), 'Size', 20,'Color','k');
hold on;
%surf(-1000:200:1000,-1000:200:1000,camera_z*ones(11,11));
xlabel('X (m) [East]');
ylabel('Y (m) [Norh]');
zlabel('Z (m)');
xlim(window_x);
ylim(window_y);
zlim([220,950]);

%load and plot DEM
load('DEMs/uavision_DEM_large');
res=30;%m/square
DEM_X=res*size(small_A,1)/-2:res:res*size(small_A,1)/2; DEM_X=DEM_X(1:size(small_A,1));
DEM_Y=res*size(small_A,2)/-2:res:res*size(small_A,2)/2; DEM_Y=DEM_Y(1:size(small_A,2));
hold on;
surf(DEM_X,DEM_Y,small_A);
%% plot height as a function of XY distance
figure;
D=sqrt(X.^2+Y.^2);
mask=D<2000;
plot(D(mask),Z(mask),'o');
hold on;
yline(cam_z(1));
hold on;
yline(mean(small_A,'all'));
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

%% plot real camera trajectory
figure();
plot3(cam_x,cam_y,cam_z,'k--o');
title("Real trajectory");
xlabel("East");
ylabel("North");

%% plot euler angles
figure();
plot(pitch);
hold on;
plot(heading);

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
plot3(xyz_est(:,1),xyz_est(:,2),xyz_est(:,3),'o');

%% check outliers
D_est=sqrt(xyz_est(:,1).^2+xyz_est(:,2).^2);
%xyz_est=xyz_est(D_est<1000,:);
bad_mask= D_est>10000; %10km
out=tracks(bad_mask);

pixels=zeros(size(tracks,2),2);
for i=1:size(tracks,2)
    pixels(i,:)=tracks(i).Points(2,:);
end
bad_pixels=pixels(bad_mask,:);
figure;imshow(I);hold on;scatter(bad_pixels(:,1),bad_pixels(:,2));

