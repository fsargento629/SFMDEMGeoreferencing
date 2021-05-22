function [pcloud,traj] = xyz_transform(xyzPoints,camPoses,gps,altitude,heading,pitch)
%Returns the recovered point cloud in world coordinates (NED) centered on
%the ground projection of the aircraft at t=0
%   1) Rotate point cloud according to pitch
%   2) Rotate according to heading
%   3) Scale point cloud using the distance between the first and last
%   point
%   4) Register the estimated trajectory to the gps trajectory

%% Compute the gps trajectory
origin = [gps(1,1), gps(1,2), altitude(1)];
[cam_x,cam_y] = latlon2local(gps(:,1),gps(:,2),altitude,origin);
cam_z=-altitude;
cam_pos=[cam_x cam_y cam_z];

%% Compute the estimated trajectory
cams=zeros(size(camPoses,1),3);
for i=1:size(camPoses,1)
    cams(i,:)=camPoses.AbsolutePose(i).Translation;
end

%% pitch
p=deg2rad(-(90+pitch(2)+180)); %-(90+pitch+180) if pitch is negative degrees
tform= affine3d(axang2tform([1 0 0 p]));
pcloud = pctransform(pointCloud(xyzPoints),tform); % magenta 1 green 2

%% heading
head=deg2rad(-heading(1)-90); %-heading
tform= affine3d(axang2tform([0 0 1 head]));
pcloud = pctransform(pcloud,tform);

%% Scale point cloud
D=sqrt(cam_x(end)^2+cam_y(end)^2+(cam_z(end)-cam_z(1))^2);
D_est=sqrt(cams(end,1)^2 + cams(end,2)^2 + cams(end,3)^2);
s=D/D_est;
tform = affine3d([s 0 0 0; 0 s 0 0; 0 0 s 0; 0 0 0 1]);
pcloud=pctransform(pcloud,tform);

%% Sum UAV altitude to the scaled point cloud 
tform=affine3d([eye(3,4);[0 0 altitude(1) 1]]);
pcloud=pctransform(pcloud,tform);

%% Register the estimated trajectory to the gps one
% 1) Scale the trajectory using the scale factor s
% 2) Rotate the trajetory over X and Z axis
% 3) Perform ICP to register the trajectories

% scale
traj=s*cams;

% rotate over Z
p=deg2rad(180);
R=axang2tform([0 0 1 p]); R=R(1:3,1:3);
traj=R*traj(:,:)'; traj=traj';
% rotate over X
a=deg2rad(180);
R=axang2tform([1 0 0 a]); R=R(1:3,1:3);
traj=R*traj(:,:)'; traj=traj';

% perform ICP to register the trajectory over the gps
[tform,registered_cams,rmse] = pcregistericp(pointCloud(traj), ... 
    pointCloud(cam_pos));
traj=[registered_cams.Location(:,1:2),-altitude];

% Show result
traj(:,1:2)=traj(:,1:2)-traj(1,1:2);

% figure;
% plot3(cam_pos(:,1),cam_pos(:,2),cam_pos(:,3),'--ko');
% hold on;
% plot3(traj(:,1),traj(:,2),traj(:,3),'r--o');
% legend("Real positions","Estimated positions");
% xlabel("X East");ylabel("Y North");

end