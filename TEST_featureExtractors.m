%% Initialization
% load images
clear;
close all;
imageDir = 'Datasets/Dataset_B';

imds = imageDatastore(imageDir);
images = cell(1, numel(imds.Files));
for i = 1:numel(imds.Files)
    I = readimage(imds, i);
    images{i} = rgb2gray(I);
end
I1=images{1};
I2=images{2};
%% show images
figure();
imshow([I1,I2]);

%% BRISK
points1=detectBRISKFeatures(I1);
points2=detectBRISKFeatures(I2);  %#ok<*NASGU>

%% FAST
points1 = detectFASTFeatures(I1);
points2 = detectFASTFeatures(I2);

%% Harris
points1 = detectHarrisFeatures(I1);
points2 = detectHarrisFeatures(I2);

%% KAZE
points1 = detectKAZEFeatures(I1);
points2 = detectKAZEFeatures(I2);

%% MinEigen
points1 = detectMinEigenFeatures(I1);
points2 = detectMinEigenFeatures(I2);

%% MSERF
points1 = detectMSERFeatures(I1);
points2 = detectMSERFeatures(I2);
%% ORB
points1 = detectORBFeatures(I1);
points2 = detectORBFeatures(I2);
%% Surf with roi
border = 50;%50
roi = [border, border, size(I1, 2)- 2*border, size(I1, 1)- 2*border];
points1   = detectSURFFeatures(I1, 'NumOctaves', 8, 'ROI', roi);
points2   = detectSURFFeatures(I2, 'NumOctaves', 8, 'ROI', roi);

%% simple SURF 
points1 = detectSURFFeatures(I1);
points2 = detectSURFFeatures(I2);

%% extract match  and visualize features
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

