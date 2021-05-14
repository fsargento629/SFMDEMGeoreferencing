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
focalLength=[1063.17,1063.17];
principalPoint=[505,270];
imageSize=[631,926]; % switched with principal on purpose
intrinsics = cameraIntrinsics(focalLength,principalPoint,imageSize);