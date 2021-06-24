%% Algorithm definitions
clear;clc;close all;
reprojection_error_threshold=1;
dataset_name='T4';
dataset=strcat("archeira/",dataset_name);
detector="SURF";
constructor="KAZE";
t0=0; dt=1; tf=29;
evaluate=false;
%% load images
samples=t0+1:dt:tf+1;

imageDir=strcat('Datasets/Blender datasets/',dataset);
load(strcat("Datasets/Blender datasets/",dataset,"/extrinsics"));
imds = imageDatastore(imageDir);

% select images (only the selected samples
images = cell(1, numel(samples));
color_images=cell(1, numel(samples));
for i=1:numel(samples)
    I = readimage(imds, samples(i));
    images{i} = rgb2gray(I);
    color_images{i}=I;
end
 % select only the desired extrinsics
 pitch=pitch(samples);
 heading=heading(samples);
 abspos=abspos(samples,:);
 

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
    dense_constructor(intrinsics,images,constructor,vSet,reprojection_error_threshold);
toc;
beep;
%% get extrinsics and transform pcl using it


% Point cloud transform
tic;
[pcl,traj]=blender_xyz_transform(xyzPoints,... 
    camPoses,abspos,heading,pitch,0);
toc;
ang=getAngles(vSet,heading,pitch);
%% remove outliers
tic;
[idx,p,tracks,reprojectionErrors]=removeOutliers(... 
    pcl,reprojectionErrors,reprojection_error_threshold,tracks); 
toc;
%% get color information for each point
color=getColor(tracks,color_images,size(p,1)); 


%% ICP and evaluate
gridstep=30;
[tform,picp,rmse,dem]=quickICP(p,abspos,origin,gridstep);
if evaluate==true
    geoEvaluate(abspos,p,tracks,dataset_name,0);
    geoEvaluate(abspos,p,tracks,dataset_name,tform);
end



% %% perform IDW
% [X,Y,Z,pidw]=inverseDistanceWeighting(p(1:10:end,:));
% %% perform ICP
% [picp,tform,rmse] = ICP(origin,abspos,X,Y,Z,p,true);