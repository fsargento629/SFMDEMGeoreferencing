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

%% compare angles
% pitch
figure; plot(pitch,'ko--');
hold on;
plot(ang(:,2),'ro--');
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
scatter3(p(:,1),p(:,2),p(:,3),10,double(color)/256,'filled');
hold on;
plot3(traj_true(:,1),traj_true(:,2),traj_true(:,3),'ro--');
xlim([min(p(:,1)),max(p(:,1))]);
ylim([min(p(:,2)),max(p(:,2))]);
title("3D scene reconstruction");
xlabel("X East [m]");
ylabel("Y north [m]");
zlabel("Z altitude [m]");
legend("Point cloud","True Trajectory");

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