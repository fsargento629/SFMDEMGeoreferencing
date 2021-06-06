%% load SFM results and ground truth
load("SFM_results/01_06_11_41");
load("Datasets/A/test");

%% test the ist pixel
i=2;
id=test_pixels(i,3);
[px,small_tracks,small_p]=getPixelsFromTrack(tracks,id,p);

%% find the 5 closest points
D=sqrt((test_pixels(i,1)-px(:,1)).^2 + (test_pixels(i,2)-px(:,2)).^2);
[D_min,idx]=mink(D,5);
% get a new pointcloud with only the 5 points
p_test=small_p(idx,:);

%% show these points
figure; imshow(images{id});
hold on; scatter(px(idx,1),px(idx,2));

%% Determine real position from gps
xy_true=getRealTraj([gps(1,:);test_lat_lon(1,:)],[0;0]);
xy_true=xy_true(2,1:2);
h=getAltitude(test_lat_lon(i,1),test_lat_lon(i,2));

p_true=[ xy_true h ];
%% determine error before ICP 
exyz=vecnorm( (p_true-p_test)');
disp(exyz);

exyz=vecnorm( (p_true(1:2)-p_test(:,1:2))');
disp(exyz);
%% perform ICP and show new error
[p_icp,tform,rmse]=ICP(gps,X,Y,Z,p_test,true);
exyz=vecnorm( (p_true-p_icp)');
disp(exyz);

exyz=vecnorm( (p_true(1:2)-p_icp(:,1:2))');
disp(exyz);