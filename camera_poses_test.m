%% clear
clear; clc;
%R = angle2dcm( roll, pitch, yaw );
%% create cameras
t=[0 0 0];
yaw=deg2rad(90-150); 
pitch=deg2rad(90-20); 
roll=deg2rad(0); 
R = angle2dcm( yaw, pitch, roll,'ZYZ' );

vset=imageviewset;
vset=addView(vset,1,rigid3d(R,t));
%% view camera
figure;camPoses=poses(vset);
plotCamera(camPoses);
xlabel('X East');ylabel('Y North');zlabel('Z Down');
set(gca, 'ZDir','reverse');