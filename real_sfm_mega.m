%% Definitions and setup
clear;clc;close all;
N=10;
reprojection_error_threshold=2;
dir='Datasets\Real_datasets\pombal_3';
detector="SURF";
scene="pombal";

% intrinsics
%load(strcat(dir,'/intrinsics'));
% focalLength=[1063.17,1063.17];
% principalPoint=[505 270];
% focalLength=[1055,1055];
% principalPoint=[505 270];
% imageSize=[631 926]; % switched with principal on purpose
% radialDistortion=[0,0];% should be=[ 0 0]
% intrinsics = cameraIntrinsics(focalLength,principalPoint,imageSize,...
%     'RadialDistortion',radialDistortion);
load(strcat(dir,'/intrinsics'));
% load extrinsics, intrinsics

load(strcat(dir,'/extrinsics'));
pitch=90-pitch;
%heading=35;

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

%% LOOP AND SAVE
for i=1:N 
    xyzPoints=0;
    while size(xyzPoints,1)<3000
        % motion estimation
        tic;
        [vSet]=motion_estimation(intrinsics,images,detector,400);
        toc;
        ang=getAngles(vSet,heading,pitch);
        
        % dense reconstruction (LKT)
        tic;
        [xyzPoints, camPoses, reprojectionErrors,tracks]...
            = dense_constructor_LKT(intrinsics,images,"Eigen001",vSet);
        toc;
        disp(size(xyzPoints,1));
    end
    % xyz transform
    load(strcat(dir,'/gps'));
    traj=getEstimatedTraj(camPoses);
    s=getScaleReal(gps,gps(:,3),traj,0.5)*1.05;
    [pcl,traj,scale]=blender_xyz_transform(xyzPoints,...
        camPoses,[0,0,origin(3)],heading,pitch,s);
    % remove outliers
    [idx,p,tracks,reprojectionErrors]=removeOutliers_real(...
        pcl,reprojectionErrors,reprojection_error_threshold,tracks,3000);
    % get color
    color=getColor(tracks,color_images,size(p,1));
    
    % ICP
    [rmse,tform,p_icp_abs] = ICP(p,[0,0,0],origin(1:2),scene,"real");
    
    
    % evaluate
    [xy,dz]=geo_evaluate_real(origin,p_icp_abs,tracks,dir,[1,2,3,4,5]);
    
    % Save?
    save_dir='large_results\Real\pombal_3\';
    formatOut = 30;
    d=datestr(now, formatOut);
    save(strcat(save_dir,d));
    disp(i);
    fprintf("--------------\n");
end
