%% load
clear;
load('large_results\Real\pombal_3.mat');
load(strcat(dir,"/gps"));
% turn the gps into XYZ
abspos=getRealTraj(gps,gps(:,3));
%% correct the heading of p and do the ICP
fixer=-25;
head=deg2rad(fixer); %heading
tform= affine3d(axang2tform([0 0 1 head]));
points0=transformPointsForward(tform,p);
[rmse,tform,pointsf] = ICP(points0,[0,0,0],origin(1:2),scene,'real');
%% geo evaluate before and after
[xy,dz]=geo_evaluate_real(origin,p,tracks,dir,[1,2,3]);
[xy0,dz0]=geo_evaluate_real(origin,points0,tracks,dir,[1,2,3]);
[xyf,dzf]=geo_evaluate_real(origin,pointsf,tracks,dir,[1,2,3]);

%% ICP for different headings
fixers=-90:5:90;
rmses=zeros(size(fixers));
i=1;
for fixer=fixers
    head=deg2rad(fixer); %heading
    tform= affine3d(axang2tform([0 0 1 head]));
    points0=transformPointsForward(tform,p);
    [rmses(i),tform,pointsf] = ICP(points0,[0,0,0],origin(1:2),scene);
    i=i+1;
    disp(i);
end
%% filter out smoke points
smoke=pointsf(:,3)>300;
pointsns=pointsf(~smoke,:); colorns=color(~smoke,:);tracksns=tracks(~smoke);
[rmse,tform,pointsnsf] = ICP(pointsns,[0,0,0],origin(1:2),scene,'real');
[xy0ns,dz0ns]=geo_evaluate_real(origin,pointsns,tracksns,dir,[1,2,3]);
[xyfns,dzfns]=geo_evaluate_real(origin,pointsnsf,tracksns,dir,[1,2,3]);

%% Test ICP with different scales
% iterative ICP
%[rmses,pointss,best_rmse,best_scale,best_tform,best_i] =...
%iterative_ICP_real(points0,origin,scene);

% scale the point cloud and compare with the default scale
clc;
scale=1.2;
% scale
translator=affine3d([eye(3,4);[0 0 -origin(3) 1]]);
pointss=transformPointsForward(translator,points0);
scaler=affine3d([scale 0 0 0; 0 scale 0 0; 0 0 scale 0; 0 0 0 1]);
pointss=transformPointsForward(scaler,pointss);
translator=affine3d([eye(3,4);[0 0 origin(3) 1]]);
pointss=transformPointsForward(translator,pointss);
% evaluate
[xy0,dz0]=geo_evaluate_real(origin,points0,tracks,dir,[1,2,3]);
fprintf("----------\n");
[xyf,dzf]=geo_evaluate_real(origin,pointss,tracks,dir,[1,2,3]);

%% loop
scales=0.8:0.02:1.4;
xy0=zeros(numel(scales),3);
dz0=xy0; xyf=xy0;dzf=xy0;
xyicp=xy0;dzicp=xy0;
rmses=zeros(numel(scales),1);
i=1;
for scale=scales
    % scale
    translator=affine3d([eye(3,4);[0 0 -origin(3) 1]]);
    pointss0=transformPointsForward(translator,points0);
    scaler=affine3d([scale 0 0 0; 0 scale 0 0; 0 0 scale 0; 0 0 0 1]);
    pointss0=transformPointsForward(scaler,pointss0);
    translator=affine3d([eye(3,4);[0 0 origin(3) 1]]);
    pointss0=transformPointsForward(translator,pointss0);
    % evaluate
    [xy0(i,:),dz0(i,:)]=geo_evaluate_real(origin,points0,tracks,dir,[1,2,3]);
    fprintf("-------------------------------\n");
    [xyf(i,:),dzf(i,:)]=geo_evaluate_real(origin,pointss0,tracks,dir,[1,2,3]);
    
    [rmses(i),tform,pointssf] = ICP(pointss0,[0,0,0],origin(1:2),scene,'real');
    [xyicp(i,:),dzicp(i,:)]=geo_evaluate_real(origin,pointssf,tracks,dir,[1,2,3]);
    i=i+1;
    disp(i);
end

% xy (no ICP)
figure; plot(scales,xyf);
title("XY error with scale correction (no ICP)");

% dz (no ICP)
figure; plot(scales,dzf);
title("Z errror with scale correction (no ICP)");

% xy (w ICP)
figure; plot(scales,xyicp);
title("XY error with scale correction (w ICP)");

% dz (w ICP)
figure; plot(scales,dzicp);
title("Z errror with scale correction (w ICP)");

% rmse and xy icp error
figure; plot(rmses,mean(xyicp),'o');
title("XY error with RMSE");

% rmse with scale
figure; plot(scales,rmses);
title("RMSE with scale correction")
%% loop scales and heading
headings=-40:2:-20;
scales=0.9:0.02:1.3;
xy0=zeros(numel(headings),numel(scales),3);
dz0=xy0; xyf=xy0;dzf=xy0;
xyicp=xy0;dzicp=xy0;
rmses=zeros(numel(headings),numel(scales));
j=1;
for head=headings
i=1;
tform= affine3d(axang2tform([0 0 1 deg2rad(head)]));
points0=transformPointsForward(tform,p);
for scale=scales
    % scale
    translator=affine3d([eye(3,4);[0 0 -origin(3) 1]]);
    pointss0=transformPointsForward(translator,points0);
    scaler=affine3d([scale 0 0 0; 0 scale 0 0; 0 0 scale 0; 0 0 0 1]);
    pointss0=transformPointsForward(scaler,pointss0);
    translator=affine3d([eye(3,4);[0 0 origin(3) 1]]);
    pointss0=transformPointsForward(translator,pointss0);
    % evaluate
    [xy0(j,i,:),dz0(j,i,:)]=geo_evaluate_real(origin,points0,tracks,dir,[1,2,3]);
    fprintf("-------------------------------\n");
    [xyf(j,i,:),dzf(j,i,:)]=geo_evaluate_real(origin,pointss0,tracks,dir,[1,2,3]);
    
    [rmses(j,i),tform,pointssf] = ICP(pointss0,[0,0,0],origin(1:2),scene,'real');
    [xyicp(j,i,:),dzicp(j,i,:)]=geo_evaluate_real(origin,pointssf,tracks,dir,[1,2,3]);
    i=i+1;
    disp([j,i]);
end
j=j+1;
end

%% plot scale and xy values
% scale and mean values (n ICP)
xymean=...
    reshape(mean(xyf),size(mean(xyf),2),size(mean(xyf),3))*...
    1/3*ones(3,1);

figure; plot(scales,xymean);
title("XY mean error and scale correction (no ICP)");
% scale and mean values (w ICP)
xymean=...
    reshape(mean(xyicp),size(mean(xyicp),2),size(mean(xyicp),3))*...
    1/3*ones(3,1);

figure; plot(scales,xymean);
title("XY mean error and scale correction (w ICP)");

% scale and min values (n ICP)
xymin=...
    reshape(min(xyf),size(min(xyf),2),size(min(xyf),3))*...
    1/3*ones(3,1);

figure; plot(scales,xymin);
title("XY min error and scale correction (no ICP)");
% scale and min values (w ICP)
xymin=...
    reshape(min(xyicp),size(min(xyicp),2),size(min(xyicp),3))*...
    1/3*ones(3,1);

figure; plot(scales,xymin);
title("XY min error and scale correction (w ICP)");

%% plot scale and dz values
% scale and mean values (n ICP)
dzmean=...
    reshape(mean(dzf),size(mean(dzf),2),size(mean(dzf),3))*...
    1/3*ones(3,1);

figure; plot(scales,dzmean);
title("Z mean error and scale correction (no ICP)");
% scale and mean values (w ICP)
dzmean=...
    reshape(mean(dzicp),size(mean(dzicp),2),size(mean(dzicp),3))*...
    1/3*ones(3,1);

figure; plot(scales,dzmean);
title("Z mean error and scale correction (w ICP)");

% scale and min values (n ICP)
dzmin=...
    reshape(min(dzf),size(min(dzf),2),size(min(dzf),3))*...
    1/3*ones(3,1);

figure; plot(scales,dzmin);
title("Z min error and scale correction (no ICP)");
% scale and min values (w ICP)
dzmin=...
    reshape(min(dzicp),size(min(dzicp),2),size(min(dzicp),3))*...
    1/3*ones(3,1);

figure; plot(scales,dzmin);
title("Z min error and scale correction (w ICP)");
%% scale and rmse
figure;
plot(scales,mean(rmses));
title("RMSE and scale correction");
figure;
xymin=...
    reshape(min(xyicp),size(min(xyicp),2),size(min(xyicp),3))*...
    1/3*ones(3,1);
 plot(scales,xymin);
title("XY error and scale correction");

%% heading and XY error
% scale and mean values (n ICP)
xymean=...
    reshape(mean(xyf,2),size(mean(xyf,2),1),size(mean(xyf,2),3))*...
    1/3*ones(3,1);

figure; plot(headings,xymean);
title("XY mean error and heading correction (no ICP)");
% scale and mean values (w ICP)
xymean=...
    reshape(mean(xyicp,2),size(mean(xyicp,2),1),size(mean(xyicp,2),3))*...
    1/3*ones(3,1);

figure; plot(headings,xymean);
title("XY mean error and heading correction (w ICP)");

% scale and min values (n ICP)
xymin=...
    reshape(min(xyf,[],2),size(headings,2),3)*...
    1/3*ones(3,1);

figure; plot(headings,xymin);
title("XY min error and heading correction (no ICP)");
% scale and min values (w ICP)
xymin=...
    reshape(min(xyicp,[],2),size(headings,2),3)*...
    1/3*ones(3,1);

figure; plot(headings,xymin);
title("XY min error and heading correction (w ICP)");