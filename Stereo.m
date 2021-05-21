%% Load images
clear;
clc;
close all;

dataset_name='B_1_2_33';
imageDir = strcat('Datasets/',dataset_name);
imds = imageDatastore(imageDir);

% Convert the images to grayscale.
images = cell(1, numel(imds.Files));
for i = 1:numel(imds.Files)
    I = readimage(imds, i);
    images{i} = rgb2gray(I);
end
I=images{1};
%% load camera parameters and extrinsics
load('intrinsics/intrinsics');
load(strcat('Datasets/',dataset_name,'/extrinsics'));

% get translation parameter
origin = [gps(1,1), gps(1,2), altitude(1)];
[cam_x,cam_y] = latlon2local(gps(:,1),gps(:,2),altitude,origin);
cam_z=-altitude;
cam_pos=[cam_x cam_y cam_z];

pitch=deg2rad(90+pitch);
roll=deg2rad(zeros(size(pitch))+0);
yaw=deg2rad(90-heading);



%% Match features on both images 
I1=images{1};
I2=images{2};

% Detect dense feature points
imagePoints1 = detectMinEigenFeatures(I1, 'MinQuality', 0.001);

% Create the point tracker
tracker = vision.PointTracker('MaxBidirectionalError', 1, 'NumPyramidLevels', 5);

% Initialize the point tracker
imagePoints1 = imagePoints1.Location;
initialize(tracker, imagePoints1, I1);

% Track the points
[imagePoints2, validIdx] = step(tracker, I2);
matchedPoints1 = imagePoints1(validIdx, :);
matchedPoints2 = imagePoints2(validIdx, :);

% Visualize candidate matches
figure; ax = axes;
showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2,'Parent',ax);
title(ax, 'Putative point matches');
legend(ax,'Matched points 1','Matched points 2');



%% Perform stereo recosntruction
camMatrix1 = cameraMatrix(intrinsics, ... 
    angle2dcm( yaw(1), pitch(1), roll(1),'ZYZ'), [0 0 0]);
camMatrix2 = cameraMatrix(intrinsics, ... 
    angle2dcm( yaw(2), pitch(2), roll(2),'ZYZ'), [cam_pos(2,1:2) 0]);

points3D = triangulate(matchedPoints1, matchedPoints2, camMatrix1, camMatrix2);

%% Estimate fundamental matrix and display epipolar inliers
% Estimate the fundamental matrix
[fMatrix, epipolarInliers] = estimateFundamentalMatrix(...
  matchedPoints1, matchedPoints2, 'Method', 'MSAC', 'NumTrials', 10000);

% Find epipolar inliers
inlierPoints1 = matchedPoints1(epipolarInliers, :);
inlierPoints2 = matchedPoints2(epipolarInliers, :);

% Display inlier matches
figure
showMatchedFeatures(I1, I2, inlierPoints1, inlierPoints2);
title('Epipolar Inliers');
%% Compute camera pose from inliers
[R, t] = cameraPose(fMatrix, intrinsics, inlierPoints1, inlierPoints2);
camMatrix1 = cameraMatrix(intrinsics, eye(3), [0 0 0]);
camMatrix2 = cameraMatrix(intrinsics, R', -t*R');

% Compute the 3-D points
points3D = triangulate(matchedPoints1, matchedPoints2, camMatrix1, camMatrix2);
%% Show 3D results
figure;imshow(I1);
mask=abs(points3D(:,3))<1000;
figure;scatter3(points3D(mask,1),points3D(mask,2),points3D(mask,3));
figure;
histogram(points3D(mask,3));
%% Show cameras
% Visualize the camera locations and orientations
cameraSize = 0.3;
figure
plotCamera('Size', cameraSize, 'Color', 'r', 'Label', '1', 'Opacity', 0);
hold on
grid on
plotCamera('Location', t, 'Orientation', R, 'Size', cameraSize, ...
    'Color', 'b', 'Label', '2', 'Opacity', 0);



%% Show results per pixel in image