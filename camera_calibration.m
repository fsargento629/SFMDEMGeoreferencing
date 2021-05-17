%% Example intriniscs
imageDir = fullfile(toolboxdir('vision'), 'visiondata', ...
      'structureFromMotion');
data = load(fullfile(imageDir, 'cameraParams.mat'));
cameraParams = data.cameraParams;
imds = imageDatastore(imageDir);
I_ex=readimage(imds, 1);
disp(cameraParams.Intrinsics);
%% Load image
I=imread('Datasets/Dataset_E/01.png');
figure;imshow(I);
%% Create intriniscs object
% these are the estimated UAVision intrinisics
focalLength=[1063.17,1063.17];
principalPoint=[505,270];
imageSize=[631,926]; % switched with principal on purpose
intrinsics = cameraIntrinsics(focalLength,principalPoint,imageSize);

%% Test intriniscs
clear;
focalLength=[1063.17,1063.17]*1.2;
principalPoint=[505,270];
imageSize=[631,926]; % switched with principal on purpose
intrinsics = cameraIntrinsics(focalLength,principalPoint,imageSize);
save('Intrinsics/bad_intrinsics','intrinsics');