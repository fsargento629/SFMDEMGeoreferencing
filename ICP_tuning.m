%% setup ICP
% load real DEM

load("DEMs/pombal_DEM.mat"); %A,R,x_res,y_res
abspos=getRealTraj(gps,gps(:,3));

% DEM to pcl
% make X and Y vectors
[c_origin,l_origin] = geographicToIntrinsic(R,origin(1),origin(2));
X= ((1:R.RasterSize(2))-c_origin )* x_res; % WEST-EAST
Y=( (-1:-1:-R.RasterSize(1)) + l_origin )*y_res; % NORTH-SOUTH
% convert matrix to pcl
C=size(X,2); L=size(Y,2);
XYZ=zeros(C*L,3);
i=1;
for l=1:L
    for c=1:C
        XYZ(i,:)=[X(c),Y(l),A(l,c)];
        i=i+1;
    end
end

%DEM=pointCloud(XYZ); % not using interpolation

% interpolate DEM to create a denser fixed pcl
x_inter=5;
y_inter=5;
F1 = scatteredInterpolant(XYZ(:,1),XYZ(:,2),XYZ(:,3));
[xq,yq] = ndgrid(min(XYZ(:,1)):x_inter:max(XYZ(:,1)),...
    min(XYZ(:,2)):y_inter:max(XYZ(:,2)));
vq1 = F1(xq,yq);
% turn matrices into pcl
N=numel(vq1);
XYZ=zeros(N,3);
XYZ(:,1)=reshape(xq,1,[]);
XYZ(:,2)=reshape(yq,1,[]);
XYZ(:,3)=reshape(vq1,1,[]);
DEM=pointCloud(XYZ);

%% ICP
gridstep=2;
p_abs=p+[abspos(1,1:2),0];
inlier_ratio=.5;
maxIterations=150;
pidw=pointCloud(p_abs);
pidw=pcdownsample(pidw,'gridAverage',gridstep);
[tform,pcl_icp,rmse]=pcregistericp(pidw,DEM,'Metric','PointToPlane',...
    'Extrapolate',false,...
    'InlierRatio',inlier_ratio,'MaxIterations',maxIterations,'Verbose',false);
% transform p and return
p_icp_abs=transformPointsForward(tform,p_abs);

% Evaluate
fprintf("------------------------\n");
disp(rmse);
points=p_icp_abs;
[xy,dz]=geo_evaluate_real(origin,points,tracks,dir,[1,2,3,4,5]);
mean(xy)


%% load and show targets
points=p_icp_abs;
targets=[1,2,3,4,5];
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

% target xy error
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


%% determine xy, dz, rmse for various scales
scales=0.80:0.0025:1.02;
rmses=zeros(size(scales));
xym=zeros(size(scales));
dzm=zeros(size(scales));
xys=zeros(numel(scales),5); dzs=xys;
%iterate over scales
for i=1:numel(scales)
    p_scaled=scalePoints(p,scales(i),gps(1,3));
    
    % ICP and evaluate
    gridstep=2;
    p_abs=p_scaled+[abspos(1,1:2),0];
    inlier_ratio=.5;
    maxIterations=150;
    pidw=pointCloud(p_abs);
    pidw=pcdownsample(pidw,'gridAverage',gridstep);
    [tform,~,rmses(i)]=pcregistericp(pidw,DEM,'Metric','PointToPlane',...
        'Extrapolate',false,...
        'InlierRatio',inlier_ratio,'MaxIterations',maxIterations,'Verbose',false);
    % transform p and return
    p_icp_abs=transformPointsForward(tform,p_abs);
    
    % Evaluate
    fprintf("------------------------\n");
    disp(i);
    points=p_icp_abs;
    [xy,dz]=geo_evaluate_real(origin,points,tracks,dir,[1,2,3,4,5]);
    xym(i)=mean(xy);
    dzm(i)=mean(dz);
    xys(i,:)=xy;
    dzs(i,:)=dz;
    
    
end

%% plot results
dzm=mean(abs(dzs'));
%mean xy with scale
figure; plot(scales,xym,'ko--');
title("Mean XY error and scale");
xlabel("Scale");
ylabel("Mean XY error [m]");
% mean dz with scale
figure; plot(scales,dzm,'ko--');
title("Mean Z error and scale");
xlabel("Scale");
ylabel("Mean Z error [m]");
% xy with scale for each target
figure; plot(scales,xys);
title("XY error and scale");
xlabel("Scale");
ylabel("XY error [m]");
legend("Target 1","Target 2","Target 3","Target 4","Target 5");
% dz with scale for each target
figure; plot(scales,dzs);
title("Z error and scale");
xlabel("Scale");
ylabel("Z error [m]");
legend("Target 1","Target 2","Target 3","Target 4","Target 5");
% rmse with scale
figure; plot(scales,rmses,'ko--');
xlabel("Scale");
ylabel("RMSE of the ICP");
title("Scale and RMSE of the ICP");
% scatter with rmse and xy mean
figure; scatter(rmses,xym);
title("RMSE of the ICP and mean XY error");
xlabel("RMSE of the ICP");
ylabel("Mean XY error [m]");
% scatter with rmse and dz mean
figure; scatter(rmses,dzm);
title("RMSE of the ICP and mean Z error");
xlabel("RMSE of the ICP");
ylabel("Mean Z error [m]");
% scatter with rmse and all xy errors
figure; scatter(rmses,xys(:,1));hold on;
scatter(rmses,xys(:,2)); hold on;
scatter(rmses,xys(:,3)); hold on;
scatter(rmses,xys(:,4)); hold on;
scatter(rmses,xys(:,5));
title("RMSE of the ICP and XY error for all targets");
xlabel("RMSE of the ICP");
ylabel("Mean XY error [m]");
legend("Target 1","Target 2","Target 3","Target 4","Target 5");
% scatter with rmse and all dz errors
figure; scatter(rmses,abs(dzs(:,1)));hold on;
scatter(rmses,abs(dzs(:,2))); hold on;
scatter(rmses,abs(dzs(:,3))); hold on;
scatter(rmses,abs(dzs(:,4))); hold on;
scatter(rmses,abs(dzs(:,5)));
title("RMSE of the ICP and Z error for all targets");
xlabel("RMSE of the ICP");
ylabel("Mean Z error [m]");
legend("Target 1","Target 2","Target 3","Target 4","Target 5");