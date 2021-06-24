%% load 
clear;
load('SFM_results/SFM_result_T4_dense.mat');
%load('SFM_results/batch_SFM_result_5.mat');p=P_stich;tracks=TRACKS;
close all;
clc;
dataset_name='T4';
%% DO ICP and show pre and post results
clc;
gridstep=30;
pitch_noise=0;
heading_noise=0;
abspos_noisy=abspos+[10,10,0];
R=axang2rotm([1 0 0 deg2rad(pitch_noise)]);
R=axang2rotm([0 0 1 deg2rad(heading_noise)])*R;

p_noisy=p*R;
p_noisy=p_noisy+[0,0,0];
[tform,picp,rmse,dem]=quickICP(p_noisy,abspos_noisy,origin,gridstep);
geoEvaluate(abspos_noisy,p_noisy,tracks,dataset_name,0);
geoEvaluate(abspos_noisy,p_noisy,tracks,dataset_name,tform);

%% show DEM
figure; pcshow(dem); title("DEM");
xlabel("X East [m]");ylabel("Y North [m]"); zlabel("Z elevation [m]");

%% create pcls
pcl=pointCloud(p+[abspos(1,1:2),0],'Color',color); % absolute p before ICP
pcwrite(pcl,'PointClouds/preICP');
pcl_icp=pctransform(pcl,tform); % absolute p after ICP
pcwrite(pcl_icp,'PointClouds/postICP');
pcwrite(dem,'PointClouds/dem');