%% load DEM
[A,R]=loadDem;
%% display important information
fprintf("----------------------\n");
fprintf("Number of images: %d\n",numel(images));
fprintf("Number of recovered points: %d\n",size(p,1));
fprintf("Mean reprojection error: %.2f\n",mean(reprojectionErrors));
fprintf("ICP RMSE: %.2f\n",rmse);
%% errors
figure; histogram(reprojectionErrors);
title("Reprojection error");

%% compare trajectories
traj_true=[abspos(:,1:2)-abspos(1,1:2) , abspos(:,3)];
figure; plot3(traj_true(:,1),traj_true(:,2),traj_true(:,3),'ko--');
hold on;
plot3(traj(:,1),traj(:,2),traj(:,3),'ro--');
title("True and estimated trajectory");
xlabel("X East [m]");
ylabel("Y north [m]");
zlabel("Z altitude [m]");
legend("True trajectory","Estimated Trajectory");
axis equal;
% dif
figure;plot3(traj_true(:,1)-traj(:,1),... 
    traj_true(:,2)-traj(:,2),traj_true(:,3)-traj(:,3),'ko--');
title("Location error");
xlabel("X East [m]");
ylabel("Y north [m]");
zlabel("Z altitude [m]");
axis equal;
%% compare angles
% pitch
figure; plot(pitch,'ko--');
hold on;
plot(-ang(:,2),'ro--');
title("True and estimated pitch");
ylabel("Pitch [º]");
legend("True","Estimated");
% heading
figure; plot(heading,'ko--');
hold on;
plot(ang(:,1),'ro--');
title("True and estimated heading");
ylabel("Heading [º]");
legend("True","Estimated");
% roll
figure;plot(ang(:,3),'ro--');
title("Estimated roll");
ylabel("Roll [º]");

%% point cloud with color
figure; pcshow(p,color); axis equal;
title("Recovered point cloud");
xlabel("X East [m]");
ylabel("Y north [m]");
zlabel("Z altitude [m]"); 
%% point cloud with real trajectory

figure;
scatter3(p(1:5:end,1),p(1:5:end,2),p(1:5:end,3),10,double(color(1:5:end,:))/256,'filled');
hold on;
plot3(traj_true(:,1),traj_true(:,2),traj_true(:,3),'ro--');
xlim([min(p(:,1)),max(p(:,1))]);
ylim([min(p(:,2)),max(p(:,2))]);
zlim([0,750]);
title("3D scene reconstruction");
xlabel("X East [m]");
ylabel("Y north [m]");
zlabel("Z altitude [m]");
legend("Point cloud","True Trajectory");
axis equal;
%% point cloud with dem (BEFORE ICP)
[demx,demy,demz,demtri] = pcl2surf(dem,false);
figure; trisurf(demtri,demx,demy,demz,'FaceAlpha',.5,'EdgeColor','none'); hold on;
scatter3(p(:,1),p(:,2),p(:,3),10,double(color)/256,'filled');
xlabel("X East [m]");
ylabel("Y north [m]");
zlabel("Z altitude [m]");
legend("DEM","Point cloud before ICP");
title("DEM and points before ICP");
%% point cloud with dem (AFTER ICP)
p2=transformPointsForward(tform,p);
[demx,demy,demz,demtri] = pcl2surf(dem,false);
figure; trisurf(demtri,demx,demy,demz,'FaceAlpha',.5,'EdgeColor','none'); hold on;
scatter3(p2(:,1),p2(:,2),p2(:,3),10,double(color)/256,'filled');
xlabel("X East [m]");
ylabel("Y north [m]");
zlabel("Z altitude [m]");
title("DEM and points after ICP");
legend("DEM","Point cloud after ICP");


%% DO ICP and show pre and post results (no noise)
% noise parameters
pitch_noise=0;
heading_noise=0;
gps_noise=[0,0,0];
altitude_noise=0;
% insert noise into point cloud
p_noisy=p+[0,0,altitude_noise];
abspos_noisy=abspos+gps_noise;
Rot=axang2rotm([0 0 1 deg2rad(heading_noise)])...
    *axang2rotm([1 0 0 deg2rad(pitch_noise)]);
p_noisy=p_noisy*Rot;
% results before and after ICP
gridstep=30;
[tform,picp,rmse,dem]=quickICP(p_noisy,abspos_noisy,origin,gridstep,A,R);
geoEvaluate(abspos_noisy,p_noisy,tracks,dataset_name,0);
geoEvaluate(abspos_noisy,p_noisy,tracks,dataset_name,tform);

% %% DO ICP and show pre and post results ( with noise)
% % noise parameters
% clc;
% pitch_noise=-5;
% heading_noise=0;
% gps_noise=[0,0];
% altitude_noise=0;
% % insert noise into point cloud
% p_noisy=p+[0,0,altitude_noise];
% abspos_noisy=abspos+[gps_noise,0];
% Rot=axang2rotm([0 0 1 deg2rad(heading_noise)])...
%     *axang2rotm([1 0 0 deg2rad(pitch_noise)]);
% p_noisy=p_noisy*Rot;
% % results before and after ICP
% gridstep=30;
% [tform,picp,rmse,dem]=quickICP(p_noisy,abspos_noisy,origin,gridstep,A,R);
% geoEvaluate(abspos_noisy,p_noisy,tracks,dataset_name,0);
% geoEvaluate(abspos_noisy,p_noisy,tracks,dataset_name,tform);

%% tolerance
load('Consistency_results\Full_consistency\t9.mat');
clc;
vanilla=mean(tolerance_results(:,6,:));
fprintf("Mean ICP with no error:\nRMSE=%.2f\n",...
    vanilla(6));
fprintf("Mean ICP scale correction: %.2f %% \n",100*(vanilla(13)-1));
fprintf("Mean raw georeferencing accuracy with no error:\nXY=%.2f m,Z=%.2f m\n",...
    vanilla(7),vanilla(8));
fprintf("Mean scaled georeferencing accuracy with no error:\nXY=%.2f m,Z=%.2f m\n",...
    vanilla(9),vanilla(10));
fprintf("Mean scaled georeferencing accuracy after ICP transform with no error:\nXY=%.2f m,Z=%.2f m\n",...
    vanilla(11),vanilla(12));



 % gps error (raw,scaled,icp)
in=tolerance_results(1,1:11,1);
raw_xy=mean(tolerance_results(:,1:11,7));
scaled_xy=mean(tolerance_results(:,1:11,9));
icp_xy=mean(tolerance_results(:,1:11,11));

figure; plot(in,raw_xy); hold on; plot(in,scaled_xy);
hold on; plot(in,icp_xy);
 % altitude error
 
 % pitch error
 
 % heading