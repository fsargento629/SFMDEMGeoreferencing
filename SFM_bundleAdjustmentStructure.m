%% clear
clear;
clc;
close all;
%%  get a list of all image file names in the directory.
dataset_name='B_1_2_11';%'A_30_1_35';
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
load(strcat('Datasets/',dataset_name,'/extrinsics'));

% get translation parameter
origin = [gps(1,1), gps(1,2), altitude(1)];
[cam_x,cam_y] = latlon2local(gps(:,1),gps(:,2),altitude,origin);
cam_z=-altitude;
cam_pos=[cam_x cam_y cam_z];

% new angles (N-E-D) %roll pitch yaw
pitch=90+pitch;
roll=zeros(5,1);
yaw=heading+90;
cam_ang=deg2rad([roll pitch yaw ] );
%%  Detect features. Increasing 'NumOctaves' helps detect large-scale
% features in high-resolution images. Use an ROI to eliminate spurious
% features around the edges of the image.
border = 50;%50
roi = [border, border, size(I, 2)- 2*border, size(I, 1)- 2*border]; %[x y width height]
%prevPoints=detectORBFeatures(I);
prevPoints   = detectSURFFeatures(I, 'NumOctaves', 8, 'ROI', roi);

%% Extract features. Using 'Upright' features improves matching, as long as
% the camera motion involves little or no in-plane rotation.
prevFeatures = extractFeatures(I, prevPoints);%, 'Upright', true);

%% Create an empty imageviewset object to manage the data associated with each
% view.
% 
vSet = imageviewset;

%% Add the first view. Place the camera associated with the first view
% and the origin, oriented along the Z-axis.
viewId = 1;
vSet = addView(vSet, viewId, rigid3d(eul2rotm(cam_ang(1,:),'XYZ'),cam_pos(1,:)), 'Points', prevPoints);
%vSet = addView(vSet, viewId, rigid3d, 'Points', prevPoints);

for i = 2:numel(images)
    % Undistort the current image. (deprec)
    I = images{i};
    
    % Detect, extract and match features.
    currPoints   = detectSURFFeatures(I, 'NumOctaves', 8, 'ROI', roi);
    %currPoints = detectORBFeatures(I);
    currFeatures = extractFeatures(I, currPoints, 'Upright', true);    
    indexPairs   = matchFeatures(prevFeatures, currFeatures);%, ...
        %'MaxRatio', .7, 'Unique',  true);
    
    % Select matched points.
    matchedPoints1 = prevPoints(indexPairs(:, 1));
    matchedPoints2 = currPoints(indexPairs(:, 2));
    
    % Add the current view to the view set.
    vSet = addView(vSet, i, rigid3d(eul2rotm(cam_ang(i,:),'XYZ'),cam_pos(i,:)), 'Points', currPoints);

    % Store the point matches between the previous and the current views.
    vSet = addConnection(vSet, i-1, i, 'Matches', indexPairs(:,:));
    
    % Find point tracks across all views.
    tracks = findTracks(vSet);

    % Get the table containing camera poses for all views.
    camPoses = poses(vSet);

    % Triangulate initial locations for the 3-D world points
    % And then  remove outliers
    xyzPoints = triangulateMultiview(tracks, camPoses, intrinsics);
   
    % remove outliers from xyzPoints
    [xyzPoints,tracks]=remove_outliers(xyzPoints,tracks,cam_pos,cam_ang);
    % Refine the 3-D world points and camera poses.
    [xyzPoints,reprojectionErrors] = bundleAdjustmentStructure(xyzPoints, ...
        tracks, camPoses, intrinsics);
    
    % Remove points with high reprojection error
    good_mask= reprojectionErrors<20;
    xyzPoints=xyzPoints(good_mask,:);
    tracks=tracks(good_mask);
    reprojectionErrors=reprojectionErrors(good_mask);
    % Store the refined camera poses.
    %vSet = updateView(vSet, camPoses);

    
    
    prevFeatures = currFeatures;
    prevPoints   = currPoints;  
    
    
    % matched points
    %figure; ax = axes; showMatchedFeatures(images{i-1},I,matchedPoints1,matchedPoints2,'Parent',ax);
    %legend(ax,'Matched points 1','Matched points 2');
end
[xyzPoints,tracks]=remove_outliers(xyzPoints,tracks,cam_pos,cam_ang);
%% save xyzpoints and camera poses
file_name=strcat('SFM_results/results_',dataset_name,'_',datestr(now,'dd-mm-yyyy HH-MM'));
save(file_name);