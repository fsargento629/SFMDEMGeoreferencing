%% Algorithm definitions
clear;clc;
reprojection_error_threshold=5;
dataset="archeira/T3";
detector="SURF";
constructor="Eigen";
%% load images
close all;
imageDir=strcat('Datasets/Blender datasets/',dataset);
imds = imageDatastore(imageDir);

% select images
images = cell(1, numel(imds.Files));
color_images=cell(1, numel(imds.Files));
for i=1:numel(imds.Files)
    I = readimage(imds, i);
    images{i} = rgb2gray(I);
    color_images{i}=I;
end

%% define intrinsics
load("intrinsics/blender_intrinsics");
% focalLength=[1063.17,1063.17];
% principalPoint=[960,540];
% imageSize=[1080,1920]; % switched with principal on purpose
% radialDistortion=[0,0];% should be=[ 0 0]
% intrinsics = cameraIntrinsics(focalLength,principalPoint,imageSize,... 
%     'RadialDistortion',radialDistortion);
% save('Intrinsics/blender_intrinsics','intrinsics');
%% motion estimation
tic;
[vSet]=motion_estimation(intrinsics,images,detector,200);
toc;


%% dense reconstruction
tic;
[xyzPoints, camPoses, reprojectionErrors,tracks]= ... 
    dense_constructor(intrinsics,images,constructor,vSet);
toc;

%% get extrinsics and transform pcl using it
load(strcat("Datasets/Blender datasets/",dataset,"/extrinsics"));
%abspos(:,1:2)=cosd(origin(1))*abspos(:,1:2); % mercator correction
% Point cloud transform
tic;
[pcl,traj]=blender_xyz_transform(xyzPoints,... 
    camPoses,abspos,heading,pitch,false);
toc;
%% remove outliers
tic;
[idx,p,tracks,reprojectionErrors]=removeOutliers(... 
    pcl,reprojectionErrors,reprojection_error_threshold,tracks); 
toc;
%% get color information for each point
color=getColor(tracks,color_images,size(p,1)); 

%% perform IDW
[X,Y,Z,pidw]=inverseDistanceWeighting(p(1:10:end,:));
%% perform ICP
[picp,tform,rmse] = ICP(origin,abspos,X,Y,Z,p,true);