function [xyzPoints, camPoses, reprojectionErrors,tracks] = dense_constructor(intrinsics,images,constructor,vSet)
%dense_constructor extract points and build a large poinc cloud using
% regular features


% Read the first image
%I = images{1};
I=undistortImage(images{1},intrinsics);
% Detect features in the first image.
prevPoints=extractPoints(I,constructor);
[prevFeatures,vpts1] = extractFeatures(I, prevPoints);


% update the vSet
vSet = updateConnection(vSet, 1, 2, 'Matches', zeros(0, 2));
vSet = updateView(vSet, 1, 'Points', prevPoints);


%% SFM loop
for i = 2:numel(images)
    % get new image
    I=undistortImage(images{i},intrinsics);
    
    % get matched points in the new image
    currPoints=extractPoints(I,constructor);
    [currFeatures,vpts2] = extractFeatures(I, currPoints);
    indexPairs   = matchFeatures(prevFeatures,  ...
        currFeatures,'MaxRatio',0.9);
    % Select matched points.
    matchedPoints1 = vpts1(indexPairs(:, 1));
    matchedPoints2 = vpts2(indexPairs(:, 2));
    
    % Clear the old matches between the points.
    if i < numel(images)
        vSet = updateConnection(vSet, i, i+1, 'Matches', zeros(0, 2));
    end
    vSet = updateView(vSet, i, 'Points', currPoints);
    
    % Store the point matches between the previous and the current views.
    vSet = updateConnection(vSet, i-1, i, 'Matches', indexPairs(:,:));
    
    % store the values extracted this loop
    prevFeatures = currFeatures;
    prevPoints   = currPoints;
    vpts1=vpts2;
    
end

% Find point tracks across all views.
tracks = findTracks(vSet);

% Find point tracks across all views.
camPoses = poses(vSet);

% Triangulate initial locations for the 3-D world points.
[xyzPoints,reprojectionErrors] = triangulateMultiview(tracks, camPoses,...
    intrinsics);
mask=reprojectionErrors<15;
xyzPoints=xyzPoints(mask,:);
tracks=tracks(mask);

% Refine the 3-D world points and camera poses.
[xyzPoints, camPoses, reprojectionErrors] = bundleAdjustment(...
    xyzPoints, tracks, camPoses, intrinsics, 'FixedViewId', 1);

end

