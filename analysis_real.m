%% load
clear;
load('large_results\Real\pombal_3\bad_4');
load(strcat(dir,"/gps"));
% turn the gps into XYZ
abspos=getRealTraj(gps,gps(:,3));
%% show with no smoke
[~,new_p,new_color,new_tracks] = remove_smoke(p_icp_abs,color,tracks);
points=new_p;
% pcl
figure;
scatter3(points(1:1:end,1)...
    ,points(1:1:end,2),points(1:1:end,3),10,...
    double(new_color(1:1:end,:))/256,'filled');
xlim([min(points(:,1)),max(points(:,1))]);
ylim([min(points(:,2)),max(points(:,2))]);
zlim([200,400]);
title("3D scene reconstruction");
xlabel("X East [m]");
ylabel("Y north [m]");
zlabel("Z altitude [m]");
axis equal;


%% geoevaluate real with no smoke
[xy,dz]=...
    geo_evaluate_real(origin,new_p,new_tracks,dir,[1,2,3,4,5])
%% Downscale and try again
fprintf("-----------------------------------\n");
rmse
xy
dz
p_scaled=scalePoints(p,0.85,gps(1,3));
% ICP
[rmse_s,tform,p_icp_abs_s] = ICP(p_scaled,[0,0,0],origin(1:2),scene,"real");
rmse_s
% evaluate
[xyscaled,dzscaled]=...
    geo_evaluate_real(origin,p_icp_abs_s,tracks,dir,[1,2,3,4,5])
%% Show real and estimated trajectories
figure; plot3(abspos(:,1),abspos(:,2),abspos(:,3),'ko--');
hold on;
plot3(traj(:,1),traj(:,2),traj(:,3),'ro--');
title("True and estimated trajectory");
xlabel("X East [m]");
ylabel("Y north [m]");
zlabel("Z altitude [m]");
legend("True trajectory","Estimated Trajectory");
axis equal;
%% point cloud with real trajectory (after ICP)
points=p_icp_abs;

figure;
scatter3(points(1:1:end,1)...
    ,points(1:1:end,2),points(1:1:end,3),10,...
    double(color(1:1:end,:))/256,'filled');
hold on;
plot3(abspos(:,1),abspos(:,2),abspos(:,3),'ro--');
xlim([min(points(:,1)),max(points(:,1))]);
ylim([min(points(:,2)),max(points(:,2))]);
zlim([0,750]);
title("3D scene reconstruction");
xlabel("X East [m]");
ylabel("Y north [m]");
zlabel("Z altitude [m]");
legend("Point cloud","True trajectory");
axis equal;
%% load targets
points=p_icp_abs;
targets=[2,3,4,5];
target_xyz_true=zeros(numel(targets),3);
target_xyz_est=zeros(numel(targets),3);
for i=targets
    load(strcat(dir,"/target_",int2str(i)));
    % real values
    [target_xyz_true(i,1),target_xyz_true(i,2),~]=...
        latlon2local(target_gps(1),target_gps(2),target_gps(3),origin);
    target_xyz_true(i,3)=target_gps(3);
    % estimated values
    target_xyz_est(i,:)=px2xyz(points,tracks,1,px,'10idw');
end
%% point cloud and targets

points=p_icp_abs;
figure;
scatter3(points(1:1:end,1)...
    ,points(1:1:end,2),points(1:1:end,3),10,...
    double(color(1:1:end,:))/256,'filled');
hold on;
plot3(abspos(:,1),abspos(:,2),abspos(:,3),'ro--');
hold on;
% true targets
scatter3(target_xyz_true(:,1),target_xyz_true(:,2),target_xyz_true(:,3),...
    100,'r'); hold on;
% estimated targets
scatter3(target_xyz_est(:,1),target_xyz_est(:,2),target_xyz_est(:,3),...
    100,'g');
xlim([min(points(:,1)),max(points(:,1))]);
ylim([min(points(:,2)),max(points(:,2))]);
zlim([0,750]);
title("3D scene reconstruction");
xlabel("X East [m]");
ylabel("Y north [m]");
zlabel("Z altitude [m]");
legend("Point cloud","True trajectory","True targets","Estimated targets");
axis equal;
%% Before and After ICP
points=p;
figure; scatter3(points(1:1:end,1)...
    ,points(1:1:end,2),points(1:1:end,3),10,...
    'r','filled'); hold on;
points=p_icp_abs;
scatter3(points(1:1:end,1)...
    ,points(1:1:end,2),points(1:1:end,3),10,...
    'g','filled');
title("PCL before and after ICP");
xlabel("X East [m]");
ylabel("Y north [m]");
zlabel("Z altitude [m]");
legend("Before ICP","After ICP");
axis equal;
%% show ALL
points=p_icp_abs;
DEM=loadDEM('pombal',origin);
[dem_x,dem_y,dem_z,dem_tri]=pcl2surf(DEM,false);

figure;
plot3(abspos(:,1),abspos(:,2),abspos(:,3),'ko--');
hold on;
trisurf(dem_tri,dem_x,dem_y,dem_z,'FaceAlpha',.5,'EdgeColor','none');
hold on;
scatter3(points(1:1:end,1)...
    ,points(1:1:end,2),points(1:1:end,3),10,...
    double(color(1:1:end,:))/256,'filled');
hold on;
% true targets
scatter3(target_xyz_true(:,1),target_xyz_true(:,2),target_xyz_true(:,3),...
    300,'rx'); hold on;
% estimated targets
scatter3(target_xyz_est(:,1),target_xyz_est(:,2),target_xyz_est(:,3),...
    300,'kx');
xlim([min(points(:,1)),max(points(:,1))]);
ylim([min(points(:,2)),max(points(:,2))]);
zlim([0,750]);
title("3D scene reconstruction");
xlabel("X East [m]");
ylabel("Y north [m]");
zlabel("Z altitude [m]");
legend("Point cloud","True trajectory","True targets","Estimated targets");
%axis equal;

%% target xy error
figure;
scatter(target_xyz_true(:,1),target_xyz_true(:,2),...
    300,'ro'); hold on;
% estimated targets
scatter(target_xyz_est(:,1),target_xyz_est(:,2),...
    300,'go'); hold on;
for i=1:numel(targets)
    plot([target_xyz_true(i,1),target_xyz_est(i,1)],...
        [target_xyz_true(i,2),target_xyz_est(i,2)],'k');
    hold on;
end
title("Real and estimated target locations");
xlabel("X East [m]");
ylabel("Y north [m]");
legend("Real target","Estimated target");
axis equal;



%% show the results
res_dir="large_results\Real\pombal_3\bad\bad_";
N=29;
xys=zeros(N,1);
dzs=zeros(N,1);
rmses=zeros(N,1);
scales=zeros(N,1);
for i=1:N
    filename=strcat(res_dir,int2str(i));
    load(filename,'xy','dz','rmse','s');
    xys(i)=mean(xy);
    dzs(i)=mean(abs(dz));
    rmses(i)=rmse;
    scales(i)=s;
end
disp(mean(xys));
disp(mean(dzs));

%% show a scatter plot
figure;
scatter(xys,dzs);
title("Georeferencing accuracy of the UAVision dataset for 12 simulations ");
xlabel("XY error [m]");
ylabel("Z error [m]");

%% filter out with rmse and scales
idx=rmses<4.0;
idx=logical(idx.*(scales<25));
% show filtered results
disp(mean(xys(idx)));
disp(mean(dzs(idx)));