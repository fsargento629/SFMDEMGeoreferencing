%% Clear
clear;
%% camera intrisics
focalLength=[1063.17,1063.17];
principalPoint=[520,250];
imageSize=[940,630];
intrinsics = cameraIntrinsics(focalLength,principalPoint,imageSize);
%% load video and show a frame 
v=VideoReader('Video FOGO_1.avi');
frame=read(v,1113);
imshow(frame);
%% Remove frames and store them


for i=1114:5:2670
    frame=read(v,i);
    frame_name=strcat(int2str((i-1114)/5 +1),'.png');
    imwrite(frame, strcat('Dataset/',frame_name));
end


%% Test matched features
% load images
I1 = imread('Dataset_A/1.png');
I2 = imread('Dataset_A/10.png');

% convert to grayscale
I1=rgb2gray(I1);
I2=rgb2gray(I2);


% detect features
points1 = detectSURFFeatures(I1);
points2 = detectSURFFeatures(I2);

% extract features
[f1, vpts1] = extractFeatures(I1, points1);
[f2, vpts2] = extractFeatures(I2, points2);

% match features
indexPairs = matchFeatures(f1, f2) ;
matchedPoints1 = vpts1(indexPairs(:, 1));
matchedPoints2 = vpts2(indexPairs(:, 2));

% Visualize candidate matches
figure; ax = axes;
showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2,'Parent',ax);
title(ax, 'Putative point matches');
legend(ax,'Matched points 1','Matched points 2');

