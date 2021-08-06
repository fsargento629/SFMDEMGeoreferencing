%% load dem and results
clear;
dem=pcread('archeira.ply');
load('large_results\T4\5.mat')
real_s=30;
%% correct scale
translator=affine3d([eye(3,4);[0 0 -abspos(1,3) 1]]);
p=transformPointsForward(translator,p);
scale=real_s/s1;
scaler=affine3d([scale 0 0 0; 0 scale 0 0; 0 0 scale 0; 0 0 0 1]);
p=transformPointsForward(scaler,p);
translator=affine3d([eye(3,4);[0 0 abspos(1,3) 1]]);
p=transformPointsForward(translator,p);
%% noise
gps=20;
alt=-20;
p_noisy=p+[0,0,alt];%[gps,gps,0];
abspos_noisy=abspos+[gps,gps,0];
%% do a icp with dem

clc;
gridstep=2;
p_abs=p_noisy+[abspos_noisy(1,1:2),0];
pidw=pointCloud(p_abs);
pidw=pcdownsample(pidw,'gridAverage',gridstep);

% register the two pcls
%[tform,picp,rmse]=pcregistercpd(pidw,dem);
[tform,picp,rmse]=pcregistericp(pidw,dem,'Metric','PointToPlane',...
    'Extrapolate',true,'InlierRatio',1,'MaxIterations',30,'Verbose',false);

disp(rmse);
[xy,dz]=geoEvaluate(abspos_noisy,p_noisy,tracks,dataset_name,0,false);
fprintf("Before ICP\n");
disp(xy); disp(dz);
[xy,dz]=geoEvaluate(abspos_noisy,p_noisy,tracks,dataset_name,tform,false);
fprintf("After ICP\n");
disp(xy); disp(dz);
pcshowpair(dem,picp);



%% loop to build gps error vector
gps=[-50,-40,-30,-20,-10,-5,0,5,10,20,30,40,50];
N=numel(gps);
gps_ers=zeros(N,4);
for i=1:N
    gps_ers(i,:)=test_tolerance...
        (dataset_name,tracks,dem,abspos,p,gps(i),0,0,0);
end
%% loop to build alt error vector
alt=[-50,-40,-30,-20,-10,-5,0,5,10,20,30,40,50];
N=numel(alt);
alt_ers=zeros(N,4);
for i=1:N
    alt_ers(i,:)=test_tolerance...
        (dataset_name,tracks,dem,abspos,p,0,alt(i),0,0);
end
%% loop to build pitch error vector
delta=[-5,-4,-3,-2,-1,-0.5,0,0.5,1,2,3,4,5];
N=numel(delta);
delta_ers=zeros(N,4);
for i=1:N
    delta_ers(i,:)=test_tolerance...
        (dataset_name,tracks,dem,abspos,p,0,0,delta(i),0);
end
%% loop to build heading error vector
phi=[-5,-4,-3,-2,-1,-0.5,0,0.5,1,2,3,4,5];
N=numel(phi);
phi_ers=zeros(N,4);
for i=1:N
    phi_ers(i,:)=test_tolerance...
        (dataset_name,tracks,dem,abspos,p,0,0,0,phi(i));
end

%% show gps results
%xy
figure; plot(gps,gps_ers(:,1),'ko--'); hold on;
plot(gps,gps_ers(:,3),'ro--');
legend("Before ICP","After ICP");
xlabel("GPS error [m]");
ylabel("Horizontal error [m]");
title("Effect of GPS error on Horizontal error");
%dz
figure; plot(gps,gps_ers(:,2),'ko--'); hold on;
plot(gps,gps_ers(:,4),'ro--');
legend("Before ICP","After ICP");
xlabel("GPS error [m]");
ylabel("Vertical error [m]");
title("Effect of GPS error on Vertical error");

%% show altitude results
%xy
figure; plot(alt,alt_ers(:,1),'ko--'); hold on;
plot(alt,alt_ers(:,3),'ro--');
legend("Before ICP","After ICP");
xlabel("Altitude error [m]");
ylabel("Horizontal error [m]");
title("Effect of Altitude error on Horizontal error");
%dz
figure; plot(alt,alt_ers(:,2),'ko--'); hold on;
plot(alt,alt_ers(:,4),'ro--');
legend("Before ICP","After ICP");
xlabel("Altitude error [m]");
ylabel("Vertical error [m]");
title("Effect of Altitude error on Vertical error");

%% show pitch results
%xy
figure; plot(delta,delta_ers(:,1),'ko--'); hold on;
plot(delta,delta_ers(:,3),'ro--');
legend("Before ICP","After ICP");
xlabel("Pitch error [º]");
ylabel("Horizontal error [m]");
title("Effect of Pitch error on Horizontal error");
%dz
figure; plot(delta,delta_ers(:,2),'ko--'); hold on;
plot(delta,delta_ers(:,4),'ro--');
legend("Before ICP","After ICP");
xlabel("Pitch error [º]");
ylabel("Vertical error [m]");
title("Effect of Pitch error on Vertical error");
%% show headingg results
%xy
figure; plot(phi,phi_ers(:,1),'ko--'); hold on;
plot(phi,phi_ers(:,3),'ro--');
legend("Before ICP","After ICP");
xlabel("Heading error [º]");
ylabel("Horizontal error [m]");
title("Effect of Heading error on Horizontal error");
%dz
figure; plot(phi,phi_ers(:,2),'ko--'); hold on;
plot(phi,phi_ers(:,4),'ro--');
legend("Before ICP","After ICP");
xlabel("Heading error [º]");
ylabel("Vertical error [m]");
title("Effect of Heading error on Vertical error");


%% loop all files and determine the error for each one
ers=zeros(10,4);
s=zeros(10,1);
for j=1:10
    load(strcat('large_results\T4\',int2str(j)));
    % correct scale
    translator=affine3d([eye(3,4);[0 0 -abspos(1,3) 1]]);
    p=transformPointsForward(translator,p);
    scale=real_s/s1;
    scaler=affine3d([scale 0 0 0; 0 scale 0 0; 0 0 scale 0; 0 0 0 1]);
    p=transformPointsForward(scaler,p);
    translator=affine3d([eye(3,4);[0 0 abspos(1,3) 1]]);
    p=transformPointsForward(translator,p);
    %determine errors
    %er_in=[normrnd(0,10),normrnd(0,10),normrnd(0,1),normrnd(0,1)];
    er_in=[0,0,0,0];
    ers(j,:)=test_tolerance...
        (dataset_name,tracks,dem,abspos,p,er_in(1),er_in(2),er_in(3),er_in(4));
    disp(j);
end
disp(ers);
%% show results
figure; scatter(ers(:,1),ers(:,2));
hold on; scatter(ers(:,3),ers(:,4));
title("Georeferencing error before and after appyling ICP");
xlabel("Horizontal error [m]");
ylabel("Vertical error [m]");
hold on;
for j=1:size(ers,1)
    plot([ers(j,1),ers(j,3)],[ers(j,2),ers(j,4)],'k');
end
legend("Before ICP","After ICP");
title("Georeferencing errors before and after ICP for a sample of Sfm results");