%% Define problem
clear;clc;close all;
batch_size=5;
dataset_name='B_1_2_33';
motion_estimator="SURF";features_per_image = 1500;
constructor="Eigen";
SURF_octave_number=8;
Upright_matching= true;
error_on_off=true;
reprojection_error_threshold=2;
save_results=false;
see_matches=false;
%% Load  images
imageDir = strcat('Datasets/',dataset_name);
imds = imageDatastore(imageDir);


% Convert the images to grayscale.
images = cell(1, numel(imds.Files));
for i = 1:numel(imds.Files)
    I = readimage(imds, i);
    images{i} = rgb2gray(I);
end
I=images{1};
%% Load intrinsics and extrinsics
load('intrinsics/intrinsics');
load(strcat('Datasets/',dataset_name,'/extrinsics'));

%% loop for each batch
tic;
N=floor(size(images,2)/batch_size); % batch number
XYZPOINTS=[];
TRAJ=[];
E=[]; %errors
for i=1:N
    % define batch
    ref= 1+(i-1)*batch_size;
    if i==N
        batch=1+(i-1)*batch_size:size(images,2); % til the end
    else    
        batch=1+(i-1)*batch_size:batch_size*i; 
    end
    
    % camera motion estimation
    [vSet]=motion_estimation(intrinsics,images(batch),motion_estimator,features_per_image);
    % Dense reconstruction
    [xyzPoints, camPoses, reprojectionErrors,tracks]= ... 
        dense_constructor(intrinsics,images(batch),constructor,vSet);
    % Transform point cloud to reference frame of first batch view
    [pcl,traj]=xyz_transform(xyzPoints,camPoses,gps(batch,:),altitude(batch),heading(batch),pitch(batch));
    % transform from first batch view to first image view
    [pcl,traj]=batch2global(... 
        pcl,traj,gps(1,:),gps(ref,:),altitude(1),altitude(ref));
    % Add points and trajectory to global points and trajectory
    XYZPOINTS=[XYZPOINTS;pcl.Location];
    TRAJ=[TRAJ;traj];
    E=[E;reprojectionErrors];
    
    
    %% Remove high reprojection error points
    mask=E<reprojection_error_threshold;
    XYZPOINTS=XYZPOINTS(mask,:);
    E=E(mask);
    disp(i);
end
toc;
%% Show resuts dense reconstruction results
% load DEM 
if exist('A','var') == 0
    load("DEMs/portugal_DEM");
    load coastlines;
end

% show 3d results
[~,~]=show3Dresults(A,R,XYZPOINTS,TRAJ,gps);

% show East distribution
figure; histogram(XYZPOINTS(:,1));
title("East coordinate histogram"); 
ylabel("Number of points");xlabel("X (East) Distance from aircraft [m]");

% show North distribution
figure; histogram(XYZPOINTS(:,2));
title("North coordinate histogram"); 
ylabel("Number of points");xlabel("Y (Nort) Distance from aircraft [m]");

% show points in 2D
figure;
scatter(XYZPOINTS(:,1),XYZPOINTS(:,2),0.2,'r*');
title("2D point distribution");
xlabel("X East [m]"); ylabel("Y North [m]");

% show height histogram
figure; histfit(XYZPOINTS(:,3));
title("Terrain height histogram"); 
ylabel("Number of points");xlabel("Terrain height [m]");

% show distance histogram (2D distance from (0,0)
D_2=sqrt(XYZPOINTS(:,1).^2 + XYZPOINTS(:,2).^2);
figure; histogram(D_2);
title("2D distance histogram"); 
ylabel("Number of points");xlabel("2D Distance from aircraft [m]");

% show height for a given distance
figure;
scatter(D_2,XYZPOINTS(:,3)); title("Height variation with 2D distance");
xlabel("Distance in 2D [m]"); ylabel("Terrain height [m]");

%% Perform IDW
[X,Y,Z,p_filtered]=inverseDistanceWeighting(XYZPOINTS);

figure;surf(X,Y,Z);hold on;
scatter3(p_filtered(:,1),p_filtered(:,2),p_filtered(:,3),'r');
xlabel('X East (m)');ylabel('Y North (m)');zlabel('Z Elevation  (m)');
title("Recovered DEM and recovered feature points");
legend("Recovered DEM","Recovered feature points");


