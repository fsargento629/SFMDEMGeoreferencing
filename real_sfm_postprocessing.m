%% load points and  scale to s=23
clc;clear;
load("large_results\Real\pombal_3\bad_20");
% rmse
% mean(xy)
% s
fprintf("------s=24.5 results------ \n");
new_s=24.5/s;
p_scaled=scalePoints(p,new_s,gps(1,3));
% ICP
[rmse_s,tform,p_icp_abs_s] = ICP(p_scaled,[0,0,0],origin(1:2),scene,"real");
rmse_s
% evaluate
[xyscaled,dzscaled]=... 
    geo_evaluate_real(origin,p_icp_abs_s,tracks,dir,[1,2,3,4,5]);
disp(mean(xyscaled));
%% show rmse and accuracy
fprintf("------Original results------ \n");
rmse
mean(xy)
%% rmse and accuracy for delta s=0.8
fprintf("------s=0.8 results------ \n");
p_scaled=scalePoints(p,0.8,gps(1,3));
% ICP
[rmse_s,tform,p_icp_abs_s] = ICP(p_scaled,[0,0,0],origin(1:2),scene,"real");
rmse_s
% evaluate
[xyscaled,dzscaled]=... 
    geo_evaluate_real(origin,p_icp_abs_s,tracks,dir,[1,2,3,4,5]);
disp(mean(xyscaled));
%% rmse and accuracy for delta s=0.85
fprintf("------s=0.85 results------ \n");
p_scaled=scalePoints(p,0.85,gps(1,3));
% ICP
[rmse_s,tform,p_icp_abs_s] = ICP(p_scaled,[0,0,0],origin(1:2),scene,"real");
rmse_s
% evaluate
[xyscaled,dzscaled]=... 
    geo_evaluate_real(origin,p_icp_abs_s,tracks,dir,[1,2,3,4,5]);
disp(mean(xyscaled));
%% rmse and accuracy for delta s=0.9
fprintf("------s=0.90 results------ \n");
p_scaled=scalePoints(p,0.90,gps(1,3));
% ICP
[rmse_s,tform,p_icp_abs_s] = ICP(p_scaled,[0,0,0],origin(1:2),scene,"real");
rmse_s
% evaluate
[xyscaled,dzscaled]=... 
    geo_evaluate_real(origin,p_icp_abs_s,tracks,dir,[1,2,3,4,5]);
disp(mean(xyscaled));
%% rmse and accuracy for delta s=0.95
fprintf("------s=0.95 results------ \n");
p_scaled=scalePoints(p,0.95,gps(1,3));
% ICP
[rmse_s,tform,p_icp_abs_s] = ICP(p_scaled,[0,0,0],origin(1:2),scene,"real");
rmse_s
% evaluate
[xyscaled,dzscaled]=... 
    geo_evaluate_real(origin,p_icp_abs_s,tracks,dir,[1,2,3,4,5]);
disp(mean(xyscaled));
