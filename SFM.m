%% Define problem
clear;clc;close all;
dataset_name='B_1_2_10';
motion_estimator="SURF";features_per_image = 1500;
constructor="Eigen";
SURF_octave_number=8;
Upright_matching= true;
error_on_off=true;
reprojection_error_threshold=5;
save_results=false;
see_matches=false;

%% Load and show images
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
%% Load intrinsics and extrinsics
load('intrinsics/intrinsics');
load(strcat('Datasets/',dataset_name,'/extrinsics'));
%% SFM
tic;
% camera motion estimation
[vSet]=motion_estimation(intrinsics,images,motion_estimator,features_per_image);
% Dense reconstruction
[xyzPoints, camPoses, reprojectionErrors,tracks]= ... 
    dense_constructor(intrinsics,images,constructor,vSet);
% Point cloud transform
[pcl,traj]=xyz_transform(xyzPoints,camPoses,gps,altitude,heading,pitch);
toc;

%% Show resuts
% load DEM 
if exist('A','var') == 0
    load("DEMs/portugal_DEM");
    load coastlines;
end

% show 3d results
p=pcl.Location;
p=p(abs(p(:,3))<500,:);
[~,~]=show3Dresults(A,R,p,traj,gps);

% show East distribution
figure; histogram(p(:,1));
title("East coordinate histogram"); 
ylabel("Number of points");xlabel("X (East) Distance from aircraft [m]");

% show North distribution
figure; histogram(p(:,2));
title("North coordinate histogram"); 
ylabel("Number of points");xlabel("Y (Nort) Distance from aircraft [m]");

% show points in 2D
figure;
scatter(p(:,1),p(:,2),0.2,'r*');
title("2D point distribution");
xlabel("X East [m]"); ylabel("Y North [m]");

% show height histogram
figure; histfit(p(:,3));
title("Terrain height histogram"); 
ylabel("Number of points");xlabel("Terrain height [m]");

% show distance histogram (2D distance from (0,0)
D_2=sqrt(p(:,1).^2 + p(:,2).^2);
figure; histogram(D_2);
title("2D distance histogram"); 
ylabel("Number of points");xlabel("2D Distance from aircraft [m]");

% show height for a given distance
figure;
scatter(D_2,p(:,3)); title("Height variation with 2D distance");
xlabel("Distance in 2D [m]"); ylabel("Terrain height [m]");

%% Perform IDW
[X,Y,Z]=inverseDistanceWeighting(p);