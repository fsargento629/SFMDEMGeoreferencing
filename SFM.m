%% Define problem
clear;clc;close all;
motion_estimator="KAZE";features_per_image = 200;
constructor="Eigen";
SURF_octave_number=8;
%Upright_matching= true;
%error_on_off=true;
reprojection_error_threshold=1;
%save_results=false;
%see_matches=false;
show_transform=false;
dataset='A';
t0=0;step=2;tf=42;

[images,color_images,samples]=initSFM(dataset,t0,step,tf);
load('intrinsics/intrinsics');
load(strcat('Datasets/',dataset,'/extrinsics'));
% filter extrinsics
gps=gps(samples,:); altitude=altitude(samples);
speed=speed(samples); heading=heading(samples); pitch=pitch(samples);

%% SFM
% camera motion estimation.
tic;
[vSet]=motion_estimation(intrinsics,images,motion_estimator,features_per_image);
toc;
% Dense reconstruction
tic;
[xyzPoints, camPoses, reprojectionErrors,tracks]= ... 
    dense_constructor(intrinsics,images,constructor,vSet);
toc;
% Point cloud transform
tic;
[pcl,traj]=xyz_transform(xyzPoints,camPoses,gps,altitude,heading,pitch,show_transform);
toc;
%remove outliers
tic;
[idx,p,tracks,reprojectionErrors]=removeOutliers(... 
    pcl,reprojectionErrors,reprojection_error_threshold,tracks); 
toc;
% get color information for each point\
color=getColor(tracks,color_images,size(p,1)); 


%% Show resuts dense reconstruction results
%% load DEM 
% if exist('A','var') == 0
%     load("DEMs/portugal_DEM"); 
% end
% 
% % show 3d results
% [~,~]=show3Dresults(A,R,p,traj,gps,heading,pitch);

[~,~]=show3Dresults(0,0,p,traj,gps,heading,pitch);

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
% x4-> 1200-1800 m
x1=reprojectionErrors(D_2<800 & D_2>600);
x2=reprojectionErrors(D_2<1000 & D_2>800);
x3=reprojectionErrors(D_2<1200 & D_2>1000);
x4=reprojectionErrors(D_2<1800 & D_2>1200);
x=[x1;x2;x3;x4];
g1 = repmat({'600-800 m'},size(x1,1),1);
g2 = repmat({'800-1000 m'},size(x2,1),1);
g3 = repmat({'1000-1200 m'},size(x3,1),1);
g4 = repmat({'1200-1800 m'},size(x4,1),1);
g = [g1; g2; g3;g4];
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

%% show estimated trajectory and orientation
real_traj=getRealTraj(gps,altitude);

% Trajectories
figure;plot3(real_traj(:,1),real_traj(:,2),real_traj(:,3),'ro--');
hold on; plot3(traj(:,1),traj(:,2),traj(:,3),'ko--');
title("Real and estimated trajectories");
legend('GPS trajectory','Estimated trajectory');
xlabel("X East [m]");ylabel("Y North [m]"); zlabel("Z altitude [m]");

% estimated relative orientations
a=camPoses2world(vSet);
showOrientation(a);

% measured orinetations
% heading
figure; plot(heading);title("Real heading in degrees");
figure; plot(pitch);title("Real pitch in degrees");

%% Perform IDW
[X,Y,Z,p_filtered]=inverseDistanceWeighting(p);

figure;surf(X,Y,Z);hold on;
scatter3(p_filtered(:,1),p_filtered(:,2),p_filtered(:,3),'r');
xlabel('X East (m)');ylabel('Y North (m)');zlabel('Z Elevation  (m)');
title("Recovered DEM and recovered feature points");
legend("Recovered DEM","Recovered feature points");

