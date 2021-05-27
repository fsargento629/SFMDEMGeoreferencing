%% Define problem
clear;clc;close all;
motion_estimator="SURF";features_per_image = 1500;
constructor="ORB";
SURF_octave_number=8;
%Upright_matching= true;
%error_on_off=true;
reprojection_error_threshold=1;
%save_results=false;
%see_matches=false;

dataset='A';
t0=20;step=2;tf=30;

[images,color_images,samples]=initSFM(dataset,t0,step,tf);
load('intrinsics/intrinsics');
load(strcat('Datasets/',dataset,'/extrinsics'));
% filter extrinsics
gps=gps(samples,:); altitude=altitude(samples);
speed=speed(samples); heading=heading(samples); pitch=pitch(samples);

%% SFM
tic;
% camera motion estimation
[vSet]=motion_estimation(intrinsics,images,motion_estimator,features_per_image);
% Dense reconstruction
[xyzPoints, camPoses, reprojectionErrors,tracks]= ... 
    dense_constructor(intrinsics,images,constructor,vSet);
% Point cloud transform
[pcl,traj]=xyz_transform(xyzPoints,camPoses,gps,altitude,heading,pitch);
%remove outliers
[idx,p,tracks,reprojectionErrors]=removeOutliers(... 
    pcl,reprojectionErrors,reprojection_error_threshold,tracks); 
% get color information for each point\
color=getColor(tracks,color_images,size(p,1)); 
toc;

%% Show resuts dense reconstruction results
% load DEM 
if exist('A','var') == 0
    load("DEMs/portugal_DEM"); 
end

% show 3d results
[~,~]=show3Dresults(A,R,p,traj,gps,heading,pitch);

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

% show error with point distance
D_2=sqrt(p(:,1).^2 + p(:,2).^2);
figure;scatter(D_2,reprojectionErrors);
title("Reprojection Error with distance");
xlabel("2D Distance [m]"); ylabel("Reprojection error [pixels]");

% show boxplot of error for each distance class
% x1->600-800 m
% x2-> 800-1000 m ,
% x3-> 1000-1200 m
x1=reprojectionErrors(D_2<800 & D_2>600);
x2=reprojectionErrors(D_2<1000 & D_2>800);
x3=reprojectionErrors(D_2<1200 & D_2>1000);
x=[x1;x2;x3];
g1 = repmat({'600-800 m'},size(x1,1),1);
g2 = repmat({'800-1000 m'},size(x2,1),1);
g3 = repmat({'1000-1200 m'},size(x3,1),1);
g = [g1; g2; g3];
figure; boxplot(x,g);
title("Reprojection error for 2D distances");
xlabel("Distance from first view");
ylabel("Reprojection error [px]");
% show distance histogram (2D distance from (0,0)
figure; histogram(D_2);
title("2D distance histogram"); 
ylabel("Number of points");xlabel("2D Distance from aircraft [m]");

% show height for a given distance
figure;
scatter(D_2,p(:,3)); title("Height variation with 2D distance");
xlabel("Distance in 2D [m]"); ylabel("Terrain height [m]");

%% Perform IDW
[X,Y,Z,p_filtered]=inverseDistanceWeighting(p);

figure;surf(X,Y,Z);hold on;
scatter3(p_filtered(:,1),p_filtered(:,2),p_filtered(:,3),'r');
xlabel('X East (m)');ylabel('Y North (m)');zlabel('Z Elevation  (m)');
title("Recovered DEM and recovered feature points");
legend("Recovered DEM","Recovered feature points");

