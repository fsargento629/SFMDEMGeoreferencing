%% clear
clear;
clc;
close all;
%% SFM parameters
dataset_name='B_1_2_10';
detector="KAZE";
features_per_image = 1500;
SURF_octave_number=8;
Upright_matching= true;
outlier_detection=true;
input_mask=[1 0 0 1 0];
error_on_off=true;
reprojection_error_threshold=40;
save_results=false;
see_matches=false;
%%  get a list of all image file names in the directory.

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
pitch=deg2rad(90+pitch);
roll=deg2rad(zeros(size(pitch))+0);
yaw=deg2rad(90-heading);
%R = angle2dcm( yaw, pitch, roll,'ZYZ' );
%%  Detect features. Increasing 'NumOctaves' helps detect large-scale
% features in high-resolution images. Use an ROI to eliminate spurious
% features around the edges of the image.
% SURF
tic;
if detector=="SURF"
    border = 50;
    %[x y width height]
    roi = [border, border, size(I, 2)- 2*border, size(I, 1)- 2*border]; 
    
    
    prevPoints   = detectSURFFeatures(I, 'NumOctaves', SURF_octave_number, 'ROI', roi);
    [prevFeatures,vpts1] = extractFeatures(I, prevPoints, 'Upright', Upright_matching);
end

% ORB
if detector=="ORB"
    prevPoints=selectStrongest(detectORBFeatures(I),features_per_image);    
    [prevFeatures,vpts1] = extractFeatures(I, prevPoints); %#ok<*NASGU>
end

% KAZE
if detector=="KAZE"
    prevPoints   = selectStrongest(detectKAZEFeatures(I),features_per_image);
    [prevFeatures,vpts1] = extractFeatures(I, prevPoints, 'Upright', true);
end


%% Create an empty imageviewset object to manage the data associated with each
% view.
% 
vSet = imageviewset;

%% Add the first view. Place the camera associated with the first view
% and the origin, oriented along the Z-axis.
viewId = 1;
vSet = addView(vSet, viewId, rigid3d(angle2dcm( yaw(1), pitch(1), roll(1),'ZYZ'),cam_pos(1,:)), 'Points', prevPoints);
%vSet = addView(vSet, viewId, rigid3d, 'Points', prevPoints);

for i = 2:numel(images)
   I = images{i};
   disp(i);
    % Detect features.
    if detector=="SURF"
        currPoints   = detectSURFFeatures(I, 'NumOctaves', SURF_octave_number, 'ROI', roi);
        [currFeatures,vpts2] = extractFeatures(I, currPoints, 'Upright', true);
    end

    if detector=="ORB"
        currPoints = selectStrongest(detectORBFeatures(I),features_per_image);
        [currFeatures,vpts2] = extractFeatures(I, currPoints);
    end

    if detector=="KAZE"
        currPoints   = selectStrongest(detectKAZEFeatures(I),features_per_image);
        [currFeatures,vpts2] = extractFeatures(I, currPoints, 'Upright', true);

    end

    % Extract and match features


    indexPairs   = matchFeatures(prevFeatures,  ... 
        currFeatures,'MaxRatio', .7, 'Unique',  true);

    % Select matched points.
    matchedPoints1 = vpts1(indexPairs(:, 1));
    matchedPoints2 = vpts2(indexPairs(:, 2));

    % Add the current view to the view set.
    vSet = addView(vSet, i, rigid3d(angle2dcm( yaw(i), pitch(i), roll(i),'ZYZ' ), ...
        cam_pos(i,:)), 'Points', currPoints);

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
    if outlier_detection== true
        [xyzPoints,tracks,~]=remove_outliers(...
            xyzPoints,tracks,[],cam_pos(i,:), ... 
            [yaw(i) pitch(i) roll(i)],input_mask);
    end
    
    % Refine the 3-D world points and camera poses
    if ~isempty(xyzPoints)
        [xyzPoints,camPoses,reprojectionErrors] = bundleAdjustment(xyzPoints, ...
            tracks, camPoses, intrinsics);
          % Store the refined camera poses.
          vSet = updateView(vSet, camPoses);
    end
    % Remove points with high reprojection error
    if error_on_off== true && ~isempty(xyzPoints)
        good_mask= reprojectionErrors<reprojection_error_threshold;
        xyzPoints=xyzPoints(good_mask,:);
        tracks=tracks(good_mask);
        reprojectionErrors=reprojectionErrors(good_mask);
    end

    

    prevFeatures = currFeatures;
    prevPoints   = currPoints;
    vpts1=vpts2;
    
    % matched points
    if see_matches ==true
        figure; ax = axes; showMatchedFeatures(images{i-1},I,matchedPoints1,matchedPoints2,'Parent',ax);
        legend(ax,'Matched points 1','Matched points 2');
    end
end
if outlier_detection== true
        [xyzPoints,tracks,reprojectionErrors]=remove_outliers(...
            xyzPoints,tracks,reprojectionErrors,cam_pos(i,:), ... 
            [yaw(i) pitch(i) roll(i)],input_mask);
end
toc;
close all;
%% save xyzpoints and camera poses
if save_results== true
    file_name=strcat('SFM_results/results_',dataset_name,'_',datestr(now,'dd-mm-yyyy HH-MM'));
    save(file_name);
end