%% load images
clear;
I1 = imread('Dataset_A/1.png');
I2 = imread('Dataset_A/10.png');
%% show images
figure();
imshow([I1,I2]);

%% Test matched features

% convert to grayscale
I1=rgb2gray(I1);
I2=rgb2gray(I2);

border = 50;%50
roi = [border, border, size(I1, 2)- 2*border, size(I1, 1)- 2*border];
points1   = detectSURFFeatures(I1, 'NumOctaves', 8, 'ROI', roi);
points2   = detectSURFFeatures(I2, 'NumOctaves', 8, 'ROI', roi);

% detect features
%points1 = detectSURFFeatures(I1);
%points2 = detectSURFFeatures(I2);

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

