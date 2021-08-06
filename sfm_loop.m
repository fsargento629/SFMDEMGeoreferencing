function [p,tracks,color,errors,traj,scale,ang,...
    abspos,pitch,heading,origin] =...
    sfm_loop(dataset_name,detector,constructor,t0,dt,tf,max_error,scene)
%dataset=strcat(scene,"/",dataset_name);
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
[xyzPoints, camPoses, errors,tracks]= ...
    dense_constructor(intrinsics,images,constructor,vSet,max_error);
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
[idx,p,tracks,errors]=removeOutliers(...
    pcl,errors,max_error,tracks);
toc;
%% get color information for each point
color=getColor(tracks,color_images,size(p,1));

end

