%% Algorithm definitions
clear;clc;close all;
reprojection_error_threshold=2;
dataset_name='T11';
detector="SURF";
constructor="KAZE";
t0=0; dt=1; tf=30;
evaluate=false;
scene="archeira";
%% load images
samples=t0+1:dt:tf+1;

imageDir=strcat('Datasets/Blender datasets/',dataset_name);
load(strcat("Datasets/Blender datasets/",dataset_name,"/extrinsics"));
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
pitch=90-pitch(samples);
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
[pcl,traj,scale]=blender_xyz_transform(xyzPoints,...
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
[rmse,tform,p_icp_abs] = ICP(p,abspos,origin,scene);
if evaluate==true
    [xy1,dz1]=geoEvaluate(abspos,p,tracks,dataset_name,0,false)
    [xy2,dz2]=geoEvaluate(abspos,p,tracks,dataset_name,tform,false)
end



% %% perform IDW
% [X,Y,Z,pidw]=inverseDistanceWeighting(p(1:10:end,:));
% %% perform ICP
% [picp,tform,rmse] = ICP(origin,abspos,X,Y,Z,p,true);