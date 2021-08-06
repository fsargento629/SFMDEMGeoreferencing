%% Definitions
clear;clc;close all;
reprojection_error_threshold=2;
dir='Datasets\Real_datasets\oeste_2';
detector="SURF";
scene="oeste";

% intrinsics
% load(strcat(dir,'/intrinsics'));
f=1400;
focalLength=[1,1]*f;% oeste;
principalPoint=[470 445]; % oeste
%principalPoint=[505 270]; %uavision
imageSize=[986 1219]; % switched with principal on purpose
radialDistortion=[0,0];% should be=[     0 0]
intrinsics = cameraIntrinsics(focalLength,principalPoint,imageSize,...
    'RadialDistortion',radialDistortion);
%load(strcat(dir,'/intrinsics'));
% load extrinsics, intrinsics

load(strcat(dir,'/extrinsics'));
pitch=90-pitch;
%heading=35;
pitch=65;
% load images
imds = imageDatastore(dir);

% select images (only the selected samples
images = cell(1, numel(imds.Files));
color_images= cell(1, numel(imds.Files));
for i=1:numel(imds.Files)
    I = readimage(imds, i);
    images{i} = rgb2gray(I);
    color_images{i}=I;
end
% motion estimation
tic;
[vSet]=motion_estimation(intrinsics,images,detector,400);
toc;
ang=getAngles(vSet,heading,pitch);
% dense reconstruction (KLT)
tic;
[xyzPoints, camPoses, reprojectionErrors,tracks]...
    = dense_constructor_LKT(intrinsics,images,"Eigen001",vSet);
toc;
% xyz transform
%s=speed*dt; % with speed+
%load(strcat(dir,'/gps_scale'));
% load(strcat(dir,'/gps'));
traj=getEstimatedTraj(camPoses);
s=14; %oeste_1
%s=169.4913/sqrt(sum(traj(end,:).^2))*0.925; % real_D=169.4913 m
%s=getScaleReal(gps,gps(:,3),traj,0.5)*1.05;
[pcl,traj,scale]=blender_xyz_transform(xyzPoints,...
    camPoses,[0,0,origin(3)],heading,pitch,s);
% remove outliers
p=pcl.Location;
inliers=abs(p(:,3))<2e3 & abs(p(:,1))<1e4 & abs(p(:,2))<1e4;
p=p(inliers,:);
tracks=tracks(inliers);
% get color
color=getColor(tracks,color_images,size(p,1));
pcshow(p,color);


% [idx,p,tracks,reprojectionErrors]=removeOutliers_real(...
%     pcl,reprojectionErrors,reprojection_error_threshold,tracks,30000);

%% show before ICP
figure;
pcshow(p,color);
title("Before ICP");
xlabel("X east [m]");
ylabel("Y north [m]");
zlabel("Z elevation [m]");
axis equal;
%% ICP
[rmse,tform,p_icp_abs] = ICP(p,[0,0,0],origin(1:2),scene,"real");

%% show after ICP
figure;
pcshow(p_icp_abs,color);
title("After ICP");
xlabel("X east [m]");
ylabel("Y north [m]");
zlabel("Z elevation [m]");
axis equal;

%% evaluate
[xy,dz]=geo_evaluate_real(origin,p_icp_abs,tracks,dir,[2,3,4,5]);
disp(mean(xy));
disp(mean(dz));

%% Save?
save_dir='large_results\Real\oeste_2\';
formatOut = 30;
d=datestr(now, formatOut);
save(strcat(save_dir,d));
% str = input("Do you want to save result (y/n)?\n",'s');
%
% if str=="y"
%     formatOut = 30;
%     d=datestr(now, formatOut);
%     save(save_dir);
% end