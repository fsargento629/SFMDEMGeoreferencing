%% setup
clear;
[A,R]=loadDem;
i=1;
real_s=30;
%% load and evaluate (simple)
ers=zeros(10,2);
s=zeros(10,1);
for j=1:10
    load(strcat('large_results\T4\',int2str(j)));
    % geo evaluate
    translator=affine3d([eye(3,4);[0 0 -abspos(1,3) 1]]);
    p=transformPointsForward(translator,p);
    scale=real_s/s1;
    scaler=affine3d([scale 0 0 0; 0 scale 0 0; 0 0 scale 0; 0 0 0 1]);
    p=transformPointsForward(scaler,p);
    translator=affine3d([eye(3,4);[0 0 abspos(1,3) 1]]);
    p=transformPointsForward(translator,p);
    [xy,dz]=geoEvaluate(abspos,p,tracks,dataset_name,0,false);
    ers(j,1:2)=[xy,dz];
    s(j)=s1;
end
disp(ers);
%% load and evaluate with quick icp
gridstep=[2,5,10,15,30];
rmse=zeros(numel(gridstep),10);
icp_ers=zeros(numel(gridstep),10,2);
for j=1:10
    load(strcat('large_results\T4\',int2str(j)));
    translator=affine3d([eye(3,4);[0 0 -abspos(1,3) 1]]);
    p=transformPointsForward(translator,p);
    scale=real_s/s1;
    scaler=affine3d([scale 0 0 0; 0 scale 0 0; 0 0 scale 0; 0 0 0 1]);
    p=transformPointsForward(scaler,p);
    translator=affine3d([eye(3,4);[0 0 abspos(1,3) 1]]);
    p=transformPointsForward(translator,p);
    for i=1:numel(gridstep)
        [tform,~,rmse(i,j),~] = ...
            quickICP(p,abspos,origin,gridstep(i),A,R,false);
        [xy,dz]=geoEvaluate(abspos,p,tracks,dataset_name,tform,false);
        icp_ers(i,j,1:2)=[xy,dz];
        
    end
    disp(j);
end

%% analyze
% xy error
for i=1:numel(gridstep)
    dif=ers(:,1:2)-reshape(icp_ers(i,:,1:2),size(icp_ers(i,:,1:2),2:3));
    mean_dif=mean(dif);
    
    disp([gridstep(i),mean_dif]);
    figure; scatter(ers(:,1),ers(:,2));
    hold on; scatter(icp_ers(i,:,1),icp_ers(i,:,2));
    title("Georeferencing error before and after appyling ICP");
    xlabel("Horizontal error [m]");
    ylabel("Vertical error [m]");
    hold on;
    for j=1:size(ers,1)
        plot([ers(j,1),icp_ers(i,j,1)],[ers(j,2),icp_ers(i,j,2)],'k');
    end
    legend("Before ICP","After ICP");
    title(int2str(gridstep(i)));
end
 %% plot err and icp err
i=1;
figure; scatter(ers(:,1),ers(:,2));
hold on; scatter(icp_ers(i,:,1),icp_ers(i,:,2));
title("Georeferencing error before and after appyling ICP");
xlabel("Horizontal error [m]");
ylabel("Vertical error [m]");
hold on;
for j=1:size(ers,1)
    plot([ers(j,1),icp_ers(i,j,1)],[ers(j,2),icp_ers(i,j,2)],'k');
end
legend("Before ICP","After ICP");
title(int2str(gridstep(i)));
title("Georeferencing errors before and after ICP for a sample of Sfm results");
%% plot scale diference and error

figure;scatter(abs(real_s-s)/real_s*100,ers(:,1));
title("Scale error and Horizontal georeferencing error");
xlabel("Scale error [%]");
ylabel("Horizontal error [m]");

figure;scatter(abs(real_s-s)/real_s*100,ers(:,2));
title("Scale error and Vertical georeferencing error");
xlabel("Scale error [%]");
ylabel("Vertical error [m]");


%% gps error analysis
i=1;
j=1;
grid_step=2;
gps=[-20,-10,-8,-6,-4,4,6,8,10,20];
gps_ers=zeros(numel(gps),10,4);
for j=1:10
    load(strcat('large_results\T4\',int2str(j)));
    % scale p correctly
    translator=affine3d([eye(3,4);[0 0 -abspos(1,3) 1]]);
    p=transformPointsForward(translator,p);
    scale=real_s/s1;
    scaler=affine3d([scale 0 0 0; 0 scale 0 0; 0 0 scale 0; 0 0 0 1]);
    p=transformPointsForward(scaler,p);
    translator=affine3d([eye(3,4);[0 0 abspos(1,3) 1]]);
    p=transformPointsForward(translator,p);
    
    for i=1:numel(gps)
        abspos_noisy=abspos+[gps(i),gps(i),0];
        [tform,~,~,~] = ...
            quickICP(p,abspos_noisy,origin,grid_step,A,R,false);
        [xy,dz]=geoEvaluate(abspos_noisy,p,tracks,dataset_name,0,false);
        gps_ers(i,j,1:2)=[xy,dz];
        [xy,dz]=geoEvaluate(abspos_noisy,p,tracks,dataset_name,tform,false);
        gps_ers(i,j,3:4)=[xy,dz];
        fprintf("%d,%d\n",i,j);
    end    
end

%% show gps results
mean_gps_er_raw_xy=mean(gps_ers(:,:,1)');
mean_gps_er_raw_dz=mean(gps_ers(:,:,2)');
mean_gps_er_icp_xy=mean(gps_ers(:,:,3)');
mean_gps_er_icp_dz=mean(gps_ers(:,:,4)');

figure; plot(gps,mean_gps_er_raw_xy,'--o');
hold on; plot(gps,mean_gps_er_icp_xy,'--o');
title("Georeferencing error before and after appyling ICP, with gps error induced");
xlabel("GPS error [m]");
ylabel("Georeferencing error [m]");
% hold on;
% for j=1:numel(gps)
%     plot([gps(j),gps(j)],[mean_gps_er_raw_xy(j),mean_gps_er_icp_xy(j)],'k');
% end
legend("Before ICP","After ICP");
%dz
figure; plot(gps,mean_gps_er_raw_dz,'--');
hold on; plot(gps,mean_gps_er_icp_dz,'--');
title("Vertical georeferencing error before and after appyling ICP, with gps error induced");
xlabel("GPS error [m]");
ylabel("Vertical georeferencing error [m]");
legend("Before ICP","After ICP");
% iterate over all datasets and compute  errors
%% altitude error analysis
alt=[-10,-8,-6,-4,-2,2,4,6,8,10];

alt_ers=zeros(numel(alt),10,4);
for j=1:10
    load(strcat('large_results\T4\',int2str(j)));
    % scale p correctly
    translator=affine3d([eye(3,4);[0 0 -abspos(1,3) 1]]);
    p=transformPointsForward(translator,p);
    scale=real_s/s1;
    scaler=affine3d([scale 0 0 0; 0 scale 0 0; 0 0 scale 0; 0 0 0 1]);
    p=transformPointsForward(scaler,p);
    translator=affine3d([eye(3,4);[0 0 abspos(1,3) 1]]);
    p=transformPointsForward(translator,p);
    
    for i=1:numel(alt)
        p_noisy=p; p_noisy(:,3)=p_noisy(:,3)+alt(i);
        [tform,~,~,~] = ...
            quickICP(p_noisy,abspos,origin,grid_step,A,R,false);
        [xy,dz]=geoEvaluate(abspos,p_noisy,tracks,dataset_name,0,false);
        alt_ers(i,j,1:2)=[xy,dz];
        [xy,dz]=geoEvaluate(abspos,p_noisy,tracks,dataset_name,tform,false);
        alt_ers(i,j,3:4)=[xy,dz];
        fprintf("%d,%d\n",i,j);
    end    
end
%% show altitude results
% mean_alt_er_raw_xy=mean(alt_ers(:,:,1)');
% mean_alt_er_raw_dz=mean(alt_ers(:,:,2)');
% mean_alt_er_icp_xy=mean(alt_ers(:,:,3)');
% mean_alt_er_icp_dz=mean(alt_ers(:,:,4)');
%xy
figure; plot(alt,mean_alt_er_raw_xy,'--');
hold on; plot(alt,mean_alt_er_icp_xy,'--');
title("Horizontal georeferencing error before and after appyling ICP, with altitude error induced");
xlabel("Altitude error [m]");
ylabel("Horizontal georeferencing error [m]");
legend("Before ICP","After ICP");
%dz
figure; plot(alt,mean_alt_er_raw_dz,'--');
hold on; plot(alt,mean_alt_er_icp_dz,'--');
title("Vertical georeferencing error before and after appyling ICP, with altitude error induced");
xlabel("Altitude error [m]");
ylabel("Vertical georeferencing error [m]");
legend("Before ICP","After ICP");
%% pitch error analysis
delta=[-2,-1.5,-1,-0.5,-0.25,0.25,0.5,1,1.5,2];
delta_ers=zeros(numel(delta),10,4);
for j=1:10
    load(strcat('large_results\T4\',int2str(j)));
    % scale p correctly
    translator=affine3d([eye(3,4);[0 0 -abspos(1,3) 1]]);
    p=transformPointsForward(translator,p);
    scale=real_s/s1;
    scaler=affine3d([scale 0 0 0; 0 scale 0 0; 0 0 scale 0; 0 0 0 1]);
    p=transformPointsForward(scaler,p);
    translator=affine3d([eye(3,4);[0 0 abspos(1,3) 1]]);
    p=transformPointsForward(translator,p);
    
    for i=1:numel(alt)
        rot=axang2rotm([1 0 0 deg2rad(delta(i))]);
        p_noisy=p*rot;
        [tform,~,~,~] = ...
            quickICP(p_noisy,abspos,origin,grid_step,A,R,false);
        [xy,dz]=geoEvaluate(abspos,p_noisy,tracks,dataset_name,0,false);
        delta_ers(i,j,1:2)=[xy,dz];
        [xy,dz]=geoEvaluate(abspos,p_noisy,tracks,dataset_name,tform,false);
        delta_ers(i,j,3:4)=[xy,dz];
        fprintf("%d,%d\n",i,j);
    end    
end
%% show pitch results
mean_delta_er_raw_xy=mean(delta_ers(:,:,1)');
mean_delta_er_raw_dz=mean(delta_ers(:,:,2)');
mean_delta_er_icp_xy=mean(delta_ers(:,:,3)');
mean_delta_er_icp_dz=mean(delta_ers(:,:,4)');
%xy
figure; plot(delta,mean_delta_er_raw_xy,'--');
hold on; plot(delta,mean_delta_er_icp_xy,'--');
title("Horizontal georeferencing error before and after appyling ICP, with pitch error induced");
xlabel("Pitch error [º]");
ylabel("Horizontal georeferencing error [m]");
legend("Before ICP","After ICP");
%dz
figure; plot(delta,mean_delta_er_raw_dz,'--');
hold on; plot(delta,mean_delta_er_icp_dz,'--');
title("Vertical georeferencing error before and after appyling ICP, with pitch error induced");
xlabel("Pitch error [º]");
ylabel("Vertical georeferencing error [m]");
legend("Before ICP","After ICP");
%% heading error analysis
phi=[-2,-1.5,-1,-0.5,-0.25,0.25,0.5,1,1.5,2];
phi_ers=zeros(numel(delta),10,4);
for j=1:10
    load(strcat('large_results\T4\',int2str(j)));
    % scale p correctly
    translator=affine3d([eye(3,4);[0 0 -abspos(1,3) 1]]);
    p=transformPointsForward(translator,p);
    scale=real_s/s1;
    scaler=affine3d([scale 0 0 0; 0 scale 0 0; 0 0 scale 0; 0 0 0 1]);
    p=transformPointsForward(scaler,p);
    translator=affine3d([eye(3,4);[0 0 abspos(1,3) 1]]);
    p=transformPointsForward(translator,p);
    
    for i=1:numel(alt)
        rot=axang2rotm([0 0 1 deg2rad(phi(i))]);
        p_noisy=p*rot;
        [tform,~,~,~] = ...
            quickICP(p_noisy,abspos,origin,grid_step,A,R,false);
        [xy,dz]=geoEvaluate(abspos,p_noisy,tracks,dataset_name,0,false);
        phi_ers(i,j,1:2)=[xy,dz];
        [xy,dz]=geoEvaluate(abspos,p_noisy,tracks,dataset_name,tform,false);
        phi_ers(i,j,3:4)=[xy,dz];
        fprintf("%d,%d\n",i,j);
    end    
end

%% show heading results
mean_phi_er_raw_xy=mean(phi_ers(:,:,1)');
mean_phi_er_raw_dz=mean(phi_ers(:,:,2)');
mean_phi_er_icp_xy=mean(phi_ers(:,:,3)');
mean_phi_er_icp_dz=mean(phi_ers(:,:,4)');
%xy
figure; plot(phi,mean_phi_er_raw_xy,'--');
hold on; plot(phi,mean_phi_er_icp_xy,'--');
title("Horizontal georeferencing error before and after appyling ICP, with heading error induced");
xlabel("Heading error [º]");
ylabel("Horizontal georeferencing error [m]");
legend("Before ICP","After ICP");
%dz
figure; plot(phi,mean_phi_er_raw_dz,'--');
hold on; plot(phi,mean_phi_er_icp_dz,'--');
title("Vertical georeferencing error before and after appyling ICP, with heading error induced");
xlabel("Heading error [º]");
ylabel("Vertical georeferencing error [m]");
legend("Before ICP","After ICP");
