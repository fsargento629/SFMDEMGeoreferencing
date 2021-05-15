%% clear
clear; clc;

%% create cameras
t=[0 0 0];
Y=20;
X=0;
Z=90+0; % 90 +heading
cam_ang=deg2rad([X Y Z]); % roll pitch yaw
R=eul2rotm(cam_ang,'XYZ');
vset=imageviewset;
vset=addView(vset,1,rigid3d(R,t));
%% view camera
figure;camPoses=poses(vset);
plotCamera(camPoses);
xlabel('X East');ylabel('Y North');zlabel('Z Down');