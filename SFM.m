%% Define problem
clear;clc;close all;
dataset_name='B_1_2_10';
motion_estimator="SURF";features_per_image = 1500;
constructor="Eigen";
SURF_octave_number=8;
Upright_matching= true;
error_on_off=true;
reprojection_error_threshold=5;
save_results=false;
see_matches=false;

%% Load and show images
imageDir = strcat('Datasets/',dataset_name);
imds = imageDatastore(imageDir);

% Display the images.
figure;
montage(imds.Files, 'Size', [3, 2]);

% Convert the images to grayscale.
images = cell(1, numel(imds.Files));
for i = 1:numel(imds.Files)
    I = readimage(imds, i);
    images{i} = rgb2gray(I);
end
I=images{1};
title('Input Image Sequence');
%% Load intrinsics and extrinsics
load('intrinsics/intrinsics');
load(strcat('Datasets/',dataset_name,'/extrinsics'));
%% camera motion estimation
[Vset]=motion_estimation(images,motion_estimator);
%% Dense reconstruction
[xyzPoints, camPoses, reprojectionErrors,tracks]= ... 
    dense_constructor(images,constructor,vSet);
%% Point cloud transform
[pcl,traj]=xyz_transform(xyzPoints,camPoses,gps,altitude,heading,pitch);
%% Show resuts
