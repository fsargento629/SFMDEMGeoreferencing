%% load results
clear;
load('SFM_results/results_05-10-2021 23-24');
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
plotCamera(camPoses(1,:), 'Size', 20,'Color','k');
hold on;
%surf(-1000:200:1000,-1000:200:1000,camera_z*ones(11,11));
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
xlim(window_x);
ylim(window_y);
zlim([0,990]);

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
plot(D,Z,'o');
hold on;
yline(camera_z);
hold on;
yline(mean(small_A,'all'));
xlabel('XY Distance from camera');
ylabel('Estimated height');

%% plot XY coordinates of points
figure();
scatter(X,Y);
hold on;
viscircles([0,0],200);

%% plot camera trajectory
camera_traj=zeros(size(camPoses,1),3);
for i=1:size(camPoses,1)
    camera_traj(i,:)=camPoses.AbsolutePose(i,1).Translation;
end
figure();
plot3(camera_traj(:,1),camera_traj(:,2),camera_traj(:,3),'k*-');

