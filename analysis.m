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
[tform,picp,rmse,dem]=quickICP(p,abspos,origin,gridstep);
geoEvaluate(abspos,p,tracks,dataset_name,0);
geoEvaluate(abspos,p,tracks,dataset_name,tform);

%% show DEM
figure; pcshow(dem); title("DEM");
xlabel("X East [m]");ylabel("Y North [m]"); zlabel("Z elevation [m]");

%% create pcls
pcl=pointCloud(p+[abspos(1,1:2),0],'Color',color); % absolute p before ICP
pcwrite(pcl,'PointClouds/preICP');
pcl_icp=pctransform(pcl,tform); % absolute p after ICP
pcwrite(pcl_icp,'PointClouds/postICP');
pcwrite(dem,'PointClouds/dem');