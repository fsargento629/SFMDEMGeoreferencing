%% Algorithm definitions
clear;clc;
reprojection_error_threshold=5;
dataset="archeira/T4";
detector="SURF";
MAX_features=200;
constructor="Eigen001";
batch_size=15;
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
%% get the scale factor
[images,~]=getImages(imds,1:numel(imds.Files));
[vSet_total]=motion_estimation(intrinsics,images,detector,200);
ttrue=abspos;
ttrue(:,1:2)=ttrue(:,1:2)-ttrue(1,1:2);
traj_total=getEstimatedTraj(vSet_total.poses);
scale=getScaleFactor(ttrue,traj_total,0,"distanceRatio");


%% batch SFM
% initialization
tic;
P=[];TRACKS=[];ERRORS=[]; COLOR=[]; 
TRAJ=[];
batch_num=floor(numel(imds.Files)/batch_size);
sizes=zeros(batch_num,1);

% loop to do local SFM
% 1) Do motion estimation for batch
% 2) Do dense reconstruction for batch
% 3) Transform pcl to world reference frame
% 4) Remove outliers
% 5) Get color information
% 6) Merge new results to the old
samples=1:batch_size;
parfor i=1:batch_num
   [p,tracks,reprojectionErrors,color,traj] = batch_construction_loop(... 
    imds,i,batch_size,abspos,heading,pitch,... 
    intrinsics,detector,constructor,MAX_features,scale,reprojection_error_threshold)

    sizes(i)=size(p,1);
    P=[P;p];
    TRACKS=[TRACKS,tracks];
    ERRORS=[ERRORS;reprojectionErrors];
    COLOR=[COLOR;color];
    TRAJ=[TRAJ;traj];
    
    fprintf("Loop %d done\n",i);
end
[scene,P_stich]=batch_stich(P,COLOR,sizes);

toc;
%% Final BA

% camPoses=vSet_total.poses;
% [P, camPoses, ERRORS] = bundleAdjustment(...
%    P, TRACKS, camPoses, intrinsics, 'FixedViewId', 1);

%% perform IDW
tic;
[X,Y,Z,PIDW]=inverseDistanceWeighting(P_stich(1:10:end,:));
toc;
%% perform ICP
[PICP,tform,rmse] = ICP(origin,abspos,X,Y,Z,P_stich,true);