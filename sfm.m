%% load and show images
clear; clc; close all;
dataset_name='A_30_1_35';
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

%% Get intrinsic parameters of the camera
load('intrinsics/intrinsics');

%% Get camera poses
% load extrinsics vector
load(strcat('Datasets/',dataset_name,'/extrinsics'));

% compute transltation between frames
origin = [gps(1,1), gps(1,2), altitude(1)];
[cam_x,cam_y,cam_z] = latlon2local(gps(:,1),gps(:,2),altitude,origin);
cam_z=-cam_z; % Down is positive
cam_p=[cam_x cam_y cam_z];
% compute rotations between frames
cam_ang=zeros(size(heading,1),3);

%% Define feature detector and initialize first view
% Use an ROI to eliminate spurious
% features around the edges of the image.
border = 50;
roi = [border, border, size(I, 2)- 2*border, size(I, 1)- 2*border];
prevPoints   = detectSURFFeatures(I, 'NumOctaves', 8, 'ROI', roi);

% Extract features. Using 'Upright' features improves matching, as long as
% the camera motion involves little or no in-plane rotation.
prevFeatures = extractFeatures(I, prevPoints, 'Upright', true);

% Create an empty imageviewset object to manage the data associated with each
% view.
vSet = imageviewset;

% Add the first view. Place the camera associated with the first view
% and the origin, oriented along the Z-axis.
viewId = 1;
vSet = addView(vSet, viewId, rigid3d, 'Points', prevPoints);
%% Loop over all images
for i = 2:numel(images)
    % Undistort the current image.
    I = images{i};
    
    % Detect, extract and match features.
    currPoints   = detectSURFFeatures(I, 'NumOctaves', 8, 'ROI', roi);
    currFeatures = extractFeatures(I, currPoints, 'Upright', true);    
    indexPairs   = matchFeatures(prevFeatures, currFeatures, ...
        'MaxRatio', .7, 'Unique',  true);
    
    % Select matched points.
    matchedPoints1 = prevPoints(indexPairs(:, 1));
    matchedPoints2 = currPoints(indexPairs(:, 2));
        
    % Compute the current camera pose in the global coordinate system 
    % relative to the first view.
    currPose = rigid3d(eul2rotm([0 0 0]),cam_p(i,:));
    
    % Add the current view to the view set.
    vSet = addView(vSet, i, currPose, 'Points', currPoints);

    % Store the point matches between the previous and the current views.
    vSet = addConnection(vSet, i-1, i,'Matches', indexPairs(:,:));
    
    % Find point tracks across all views.
    tracks = findTracks(vSet);

    % Get the table containing camera poses for all views.
    camPoses = poses(vSet);

    % Triangulate initial locations for the 3-D world points.
    xyzPoints = triangulateMultiview(tracks, camPoses, intrinsics);
    
    % remove outliers from xyzPoints
    D=sqrt(xyzPoints(:,1).^2+xyzPoints(:,2).^2);
    good_mask=D<5000;
    tracks=tracks(good_mask);
    xyzPoints=xyzPoints(good_mask,:);
    
    % Refine the 3-D world points and camera poses.
    [xyzPoints, reprojectionErrors] = bundleAdjustmentStructure(xyzPoints, ...
        tracks, camPoses, intrinsics);

    % Store the refined camera poses.
    vSet = updateView(vSet, camPoses);

    prevFeatures = currFeatures;
    prevPoints   = currPoints;  
end


%% Display results
figure;plot3(xyzPoints(:,1),xyzPoints(:,2),xyzPoints(:,3),'ro');
hold on;
plotCamera(camPoses(1,:));
figure;plot(xyzPoints(:,1),xyzPoints(:,2),'o');
figure; plot(xyzPoints(:,3));
%% Transform results using the first view altitude, pitch and heading