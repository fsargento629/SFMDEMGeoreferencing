function [xyzPoints, camPoses, reprojectionErrors,tracks] = dense_constructorB(intrinsics,images,constructor,vSet)
%DENSE_CONSTRUCTOR extract points and construct a large dense pointcloud
%   Detailed explanation goes here

% Read the first image
%I = images{1};
I=undistortImage(images{1},intrinsics);
% Detect corners in the first image.
if constructor=="Eigen"
    prevPoints = detectMinEigenFeatures(I, 'MinQuality', 0.001);
elseif constructor=="KAZE"
        prevPoints = detectKAZEFeatures(I);
elseif constructor=="ORB"
        prevPoints = detectORBFeatures(I);
elseif constructor=="SURF"
        prevPoints = detectSURFFeatures(I);
end
% Extract features
prevFeatures = extractFeatures(I, prevPoints);

% Store the dense points in the view set.

vSet = updateConnection(vSet, 1, 2, 'Matches', zeros(0, 2));
vSet = updateView(vSet, 1, 'Points', prevPoints);

% Track the points across all views.
for i = 2:numel(images)
    % Read and undistort the current image.
    %I=images{i}; 
    I=undistortImage(images{i},intrinsics);
    
    % extract new points
    if constructor=="Eigen"
        currPoints = detectMinEigenFeatures(I, 'MinQuality', 0.001);
    elseif constructor=="KAZE"
        currPoints = detectKAZEFeatures(I);
    elseif constructor=="ORB"
        currPoints = detectORBFeatures(I);
    elseif constructor=="SURF"
        currPoints = detectSURFFeatures(I);
    end
    
    % extract and match features.
    currFeatures = extractFeatures(I, currPoints);
    indexPairs   = matchFeatures(prevFeatures, currFeatures);
    
    
    
    % Clear the old matches between the points.
    if i < numel(images)
        vSet = updateConnection(vSet, i, i+1, 'Matches', zeros(0, 2));
    end
    vSet = updateView(vSet, i, 'Points', currPoints);
    
    % Store the point matches in the view set.      
    vSet = updateConnection(vSet, i-1, i, 'Matches', indexPairs);
end

% Find point tracks across all views.
tracks = findTracks(vSet);

% Find point tracks across all views.
camPoses = poses(vSet);

% Triangulate initial locations for the 3-D world points.
xyzPoints = triangulateMultiview(tracks, camPoses,...
    intrinsics);

% Refine the 3-D world points and camera poses.
[xyzPoints, camPoses, reprojectionErrors] = bundleAdjustment(...
   xyzPoints, tracks, camPoses, intrinsics, 'FixedViewId', 1);

end

