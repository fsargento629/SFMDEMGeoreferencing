%% load problem
clear;
close all;
dataset='A';
t0=0;step=2;tf=30;

[images,color_images,samples]=initSFM(dataset,t0,step,tf);
load('intrinsics/intrinsics');
load(strcat('Datasets/',dataset,'/extrinsics'));
% filter extrinsics
gps=gps(samples,:); altitude=altitude(samples);
speed=speed(samples); heading=heading(samples); pitch=pitch(samples);

%% motion estimation
I=undistortImage(images{1},intrinsics);
prevPoints   = selectStrongest(detectKAZEFeatures(I),200);

% show points
% figure; imshow(I);hold on;
% scatter(prevPoints.Location(:,1),prevPoints.Location(:,2));

%  extract features
prevFeatures=extractFeatures(I,prevPoints);

% Create view set and add the first view 
vSet=imageviewset;
vSet=addView(vSet,1,rigid3d,'Points',prevPoints);

%% loop all the images 
% 1) extract features
% 2) Compute the current camera pose relative to the 1st view
% 3) 

for i=2:numel(images)
    I=undistortImage(images{i},intrinsics);
    currPoints   = selectStrongest(detectKAZEFeatures(I),200);
    % extract and match features.
    currFeatures = extractFeatures(I, currPoints);
    indexPairs   = matchFeatures(prevFeatures, currFeatures);
    
    % Select only matched points.
    matchedPoints1 = prevPoints(indexPairs(:, 1));
    matchedPoints2 = currPoints(indexPairs(:, 2));
    
    
    
    [relativeOrient, relativeLoc, inlierIdx] = EstimateRelativePose(...
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
    
%     %Refine the 3-D world points and camera poses.
%     [xyzPoints, camPoses, reprojectionErrors] = bundleAdjustment(xyzPoints, ...
%         tracks, camPoses, intrinsics, 'FixedViewId', 1);
%     %Store the refined camera poses.
%     vSet = updateView(vSet, camPoses);


    % store the features for the next loop   
    prevFeatures = currFeatures;
    prevPoints   = currPoints;
end

%% post processing
T=getEstimatedTraj(vSet.poses); showTraj(T);

% show gps
X=getRealTraj(gps,altitude);
showTraj(X);

s=getScaleFactor(X,T);traj=T*s;

showTraj(traj);