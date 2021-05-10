%% clear
clear;
clc;
close all;
%%  get a list of all image file names in the directory.
imageDir = 'Datasets/Dataset_C';
%imageDir = 'Dataset_A';
imds = imageDatastore(imageDir);

% Display the images.
figure
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
%load('intrinsics/intrinsics_postOCR');
load('intrinsics/intrinsics_uavision_crop');

%% get initial pose
pitch=deg2rad(-90)+deg2rad(-10); 
roll=deg2rad(0);
yaw=deg2rad(72);
camera_z=939;%m
%%  Detect features. Increasing 'NumOctaves' helps detect large-scale
% features in high-resolution images. Use an ROI to eliminate spurious
% features around the edges of the image.
border = 50;%50
roi = [border, border, size(I, 2)- 2*border, size(I, 1)- 2*border]; %[x y width height]
%prevPoints=detectORBFeatures(I);
prevPoints   = detectSURFFeatures(I, 'NumOctaves', 8, 'ROI', roi);

%% Extract features. Using 'Upright' features improves matching, as long as
% the camera motion involves little or no in-plane rotation.
prevFeatures = extractFeatures(I, prevPoints, 'Upright', true);

%% Create an empty imageviewset object to manage the data associated with each
% view.
% 
vSet = imageviewset;

%% Add the first view. Place the camera associated with the first view
% and the origin, oriented along the Z-axis.
viewId = 1;
vSet = addView(vSet, viewId, rigid3d(eul2rotm([roll pitch yaw],'XYZ'),[0 0 camera_z]), 'Points', prevPoints);
%vSet = addView(vSet, viewId, rigid3d, 'Points', prevPoints);

for i = 2:numel(images)
    % Undistort the current image. (deprec)
    I = images{i};
    
    % Detect, extract and match features.
    currPoints   = detectSURFFeatures(I, 'NumOctaves', 8, 'ROI', roi);
    %currPoints = detectORBFeatures(I);
    currFeatures = extractFeatures(I, currPoints, 'Upright', true);    
    indexPairs   = matchFeatures(prevFeatures, currFeatures, ...
        'MaxRatio', .7, 'Unique',  true);
    
    % Select matched points.
    matchedPoints1 = prevPoints(indexPairs(:, 1));
    matchedPoints2 = currPoints(indexPairs(:, 2));
    
    
    
    
    % Estimate the camera pose of current view relative to the previous view.
    % The pose is computed up to scale, meaning that the distance between
    % the cameras in the previous view and the current view is set to 1.
    % This will be corrected by the bundle adjustment.
    [relativeOrient, relativeLoc, inlierIdx] = helperEstimateRelativePose(...
        matchedPoints1, matchedPoints2, intrinsics);
    
    % Get the table containing the previous camera pose.
    prevPose = poses(vSet, i-1).AbsolutePose;
    relPose  = rigid3d(relativeOrient, relativeLoc);
        
    % Compute the current camera pose in the global coordinate system 
    % relative to the first view.
    currPose = rigid3d(relPose.T * prevPose.T);
    
    % Add the current view to the view set.
    vSet = addView(vSet, i, currPose, 'Points', currPoints);

    % Store the point matches between the previous and the current views.
    vSet = addConnection(vSet, i-1, i, relPose, 'Matches', indexPairs(inlierIdx,:));
    
    % Find point tracks across all views.
    tracks = findTracks(vSet);

    % Get the table containing camera poses for all views.
    camPoses = poses(vSet);

    % Triangulate initial locations for the 3-D world points.
    xyzPoints = triangulateMultiview(tracks, camPoses, intrinsics);
    
    % Refine the 3-D world points and camera poses.
    [xyzPoints, camPoses, reprojectionErrors] = bundleAdjustment(xyzPoints, ...
        tracks, camPoses, intrinsics, 'FixedViewId', 1, ...
        'PointsUndistorted', true);

    % Store the refined camera poses.
    vSet = updateView(vSet, camPoses);

    
    
    prevFeatures = currFeatures;
    prevPoints   = currPoints;  
    
    
    % matched points
    figure; ax = axes;
    showMatchedFeatures(images{i-1},I,matchedPoints1,matchedPoints2,'Parent',ax);
    title(ax, 'Putative point matches');
    legend(ax,'Matched points 1','Matched points 2');
end

%% save xyzpoints and camera poses
%file_name=strcat('SFM_results/results_',datestr(now,'mm-dd-yyyy HH-MM'));
%save(file_name,'xyzPoints','camPoses','camera_z');