%% Algorithm definitions
clear;clc;
reprojection_error_threshold=5;
dataset="archeira/T4";
detector="SURF";
MAX_features=200;
constructor="Eigen001";
batch_size=6;
%% load image directory
close all;
imageDir=strcat('Datasets/Blender datasets/',dataset);
imds = imageDatastore(imageDir);

%% define intrinsics
load("intrinsics/blender_intrinsics");
% focalLength=[1063.17,1063.17];
% principalPoint=[960,540];
% imageSize=[1080,1920]; % switched with principal on purpose
% radialDistortion=[0,0];% should be=[ 0 0]
% intrinsics = cameraIntrinsics(focalLength,principalPoint,imageSize,... 
%     'RadialDistortion',radialDistortion);
% save('Intrinsics/blender_intrinsics','intrinsics');

%% load extrinsics
load(strcat("Datasets/Blender datasets/",dataset,"/extrinsics"));
%% batch SFM
% initialization
Points=[];TRACKS=[];ERRORS=[]; COLOR=[]; 
TRAJ=[];
batch_num=floor(numel(imds.Files)/batch_size);


% loop to do local SFM
% 1) Do motion estimation for batch
% 2) Do dense reconstruction for batch
% 3) Transform pcl to world reference frame
% 4) Remove outliers
% 5) Get color information
% 6) Merge new results to the old
for i=1:batch_num
    tic;
    % 0) select samples and images to use
    if i<batch_num
        samples= 1+(i-1)*batch_size:i*batch_size;
    else
        samples=1+(i-1)*batch_size:numel(imds.Files);
    end
    [images,color_images]=getImages(imds,samples);
    % 1) motion estimation
    [vSet]=motion_estimation(intrinsics,images,detector,MAX_features);
    fprintf("Motion estimation done\n");
    % 2) dense reconstruction
    [xyzPoints, camPoses, reprojectionErrors,tracks]= ... 
    dense_constructor_LKT(intrinsics,images,constructor,vSet);
    fprintf("Dense reconstruction done\n");
    % 3) Coordinate transformation
    [p,traj]=blender_xyz_transform(xyzPoints,... 
    camPoses,abspos(samples,:),heading(samples),pitch(samples));
    % 4) Outlier removal
    [idx,p,tracks,reprojectionErrors]=removeOutliers(... 
    p,reprojectionErrors,reprojection_error_threshold,tracks);
    % 5) Get color information
    color=getColor(tracks,color_images,size(p,1)); 
    % 6) Merge results
    deltaxy=(abspos(samples(1),1:2)-abspos(1,1:2));
    traj(:,1:2)=traj(:,1:2) - deltaxy;
    p(:,1:2)=p(:,1:2)-deltaxy;
    
    for j=1:size(tracks,2)
        tracks(j).ViewIds=tracks(j).ViewIds + (i-1)*batch_size;
    end
    
    Points=[Points;p];
    TRACKS=[TRACKS,tracks];
    ERRORS=[ERRORS;reprojectionErrors];
    COLOR=[COLOR;color];
    TRAJ=[TRAJ;traj];
    toc;
    fprintf("Loop %d done\n",i);
end
