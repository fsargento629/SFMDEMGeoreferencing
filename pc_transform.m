%% load points and camera poses
clear;
load('pcloud');
%% plot "real" camera poses
origin = [gps(1,1), gps(1,2), altitude(1)];
[cam_x,cam_y] = latlon2local(gps(:,1),gps(:,2),altitude,origin);
cam_z=-altitude;
cam_pos=[cam_x cam_y cam_z];
figure;
plot3(cam_pos(:,1),cam_pos(:,2),cam_pos(:,3),'--ko');
set(gca, 'ZDir','reverse')
%% plot estimated camera poses
cams=zeros(size(camPoses,1),3);
for i=1:size(camPoses,1)
    cams(i,:)=camPoses.AbsolutePose(i).Translation;
end
figure; plot3(cams(:,1),cams(:,2),cams(:,3),'r--o');

%% Show original pointcloud
figure; pcshow(xyzPoints);
xlabel("X");ylabel("Y");zlabel("Z");
zlim([0,30]);
%% first rotate the point cloud
% yaw=0;
% p=deg2rad(90-20);
% roll=0;
% R=angle2dcm( yaw, p, roll,'ZYZ');
% eul = [0 p 0];
% A = eul2tform(eul);
% tform = affine3d(A);
% pcloud2 = pctransform(pointCloud(xyzPoints),tform);
% figure;
% pcshow(pcloud2);
% xlabel("X");ylabel("Y");zlabel("Z");
% zlim([0,30]);

%% pitch
p=deg2rad(-(90+pitch(2)+180)); %-(90+pitch) if pitch is negative degrees
tform= affine3d(axang2tform([1 0 0 p]));
pcloud2 = pctransform(pointCloud(xyzPoints),tform); % magenta 1 green 2
figure;
pcshowpair(pointCloud(xyzPoints),pcloud2);
xlabel("X East");ylabel("Y North");zlabel("Z down");
%zlim([-1,30]);

%% heading
head=deg2rad(-heading(1)); %-heading
tform= affine3d(axang2tform([0 0 1 head]));
pcloud3 = pctransform(pcloud2,tform); % magenta 1 green 2
figure;
pcshowpair(pcloud2,pcloud3);
xlabel("X East");ylabel("Y North");zlabel("Z down");
%zlim([-30,-1]);

%% Scale point cloud using the total distances

% in real life
D=0;
for i=2:size(camPoses,1)
    d=sqrt( (cam_x(i)-cam_x(i-1))^2 + (cam_y(i)-cam_y(i-1))^2 + (cam_z(i)-cam_z(i-1))^2);
    D=D+d;
end
disp(D);

% in the cloud
D_est=0;
for i=2:size(camPoses,1) 
    d=sqrt( (cams(i,1)-cams(i-1,1))^2 + (cams(i,2)-cams(i-1,2))^2 + (cams(i,3)-cams(i-1,3))^2);
    D_est=D_est+d;
end
disp(D_est);
s=D/D_est;
disp(s);

tform = affine3d([s 0 0 0; 0 s 0 0; 0 0 s 0; 0 0 0 1]);

pcloud4=pctransform(pcloud3,tform);
figure;pcshow(pcloud4);set(gca, 'ZDir','reverse');
xlabel("X East");ylabel("Y North");zlabel('Z Down');
%% scale point cloud using the final distance
D=sqrt(cam_x(end)^2+cam_y(end)^2+(cam_z(end)-cam_z(1))^2);
D_est=sqrt(cams(end,1)^2 + cams(end,2)^2 + cams(end,3)^2);
s=D/D_est;
%%  sum altitude

tform=affine3d([eye(3,4);[0 0 altitude(1) 1]]);
pcloudf=pctransform(pcloud4,tform);
figure;
pcshow(pcloudf);
xlabel("X East");ylabel("Y North");zlabel("Z down");
% set(gca, 'ZDir','reverse');
%% compare the real and scaled trajectories
scaled_cams=cams*s;
%scaled_cams(:,3)=-altitude;
figure;
plot3(cam_pos(:,1),cam_pos(:,2),cam_pos(:,3),'--ko');
hold on;
plot3(scaled_cams(:,1),scaled_cams(:,2),scaled_cams(:,3),'r--o');
legend("Real positions","Estimated positions");
xlabel("X East");ylabel("Y North");zlabel('Z Down');

%% rotate scaled trajectory
p=deg2rad(190);
R=axang2tform([0 0 1 p]); R=R(1:3,1:3);
new_cams=R*scaled_cams(:,:)';
new_cams=new_cams';

figure;plot3(cam_pos(:,1),cam_pos(:,2),cam_pos(:,3),'--ko');
hold on; plot3(new_cams(:,1),new_cams(:,2),new_cams(:,3),'r--o');
title("Real and transformed scaled trajs");
xlabel("X East");ylabel("Y North"); zlabel('Z Down');

a=deg2rad(180);
R=axang2tform([1 0 0 a]); R=R(1:3,1:3);
new_cams=R*new_cams(:,:)';
new_cams=new_cams';

figure;plot3(cam_pos(:,1),cam_pos(:,2),cam_pos(:,3),'--ko');
hold on; plot3(new_cams(:,1),new_cams(:,2),new_cams(:,3),'r--o');
title("Real and transformed scaled trajs");
xlabel("X East");ylabel("Y North"); zlabel('Z Down');

%% register the recovered point cloud to the real one


[tform,registered_cams,rmse] = pcregistericp(pointCloud(new_cams), ... 
    pointCloud(cam_pos));

% [tform,registered_cams,rmse] = pcregistericp(pointCloud(scaled_cams), ... 
%     pointCloud(cam_pos), ... 
%     'InitialTransform',affine3d(axang2tform([0 0 1 deg2rad(190)])));

figure;
plot3(cam_pos(:,1),cam_pos(:,2),cam_pos(:,3),'--ko');
hold on;
plot3(registered_cams.Location(:,1),registered_cams.Location(:,2),registered_cams.Location(:,3),'r--o');
legend("Real positions","Estimated positions");
xlabel("X East");ylabel("Y North");

% set the Z to altitude
final_cams=[registered_cams.Location(:,1:2),-altitude];
figure;
plot3(cam_pos(:,1),cam_pos(:,2),cam_pos(:,3),'--ko');
hold on;
plot3(final_cams(:,1),final_cams(:,2),final_cams(:,3),'r--o');
legend("Real positions","Estimated positions");
xlabel("X East");ylabel("Y North");


%% 2D ICP
gps_traj=pointCloud([cam_pos(:,1:2) zeros(size(cam_pos,1),1)]);   
est_traj=pointCloud([scaled_cams(:,1:2) zeros(size(cam_pos,1),1)]);

%[tform,cams2d,rmse] = pcregistericp(est_traj,gps_traj,...
    %'InitialTransform',affine3d(axang2tform([0 0 1 deg2rad(190)])));
[tform,cams2d,rmse] = pcregistericp(est_traj,gps_traj);    
%registered_cams=pctransform(pointCloud(scaled_cams),tform);
figure;
plot3(cam_pos(:,1),cam_pos(:,2),zeros(size(cam_pos,1),1),'--ko');
hold on;
plot3(cams2d.Location(:,1),cams2d.Location(:,2),cams2d.Location(:,3),'r--o');
legend("Real positions","Estimated positions");
xlabel("X East");ylabel("Y North");