%% setup
clear;
N=20; % number of tries
max_error=2;
scene="vila_real";
dataset_name='V1\';
dataset=strcat(scene,"/",dataset_name);
detector="SURF";
constructor="KAZE";
t0=0; dt=1; tf=30;
%% sfm, icp, georefer loop
%real_s=43.5982; % T11
%real_s=30;%T4 
real_s=10; %T8 and T9
for i=1:N
    % sfm
    [p,tracks,color,errors,traj,s1,ang,...
        abspos,pitch,heading,origin] =...
        sfm_loop(dataset_name,detector,constructor,t0,dt,tf,max_error,...
        scene);
    %% correct scale
    p_bad_scale=p;
    translator=affine3d([eye(3,4);[0 0 -abspos(1,3) 1]]);
    p=transformPointsForward(translator,p);
    scale=real_s/s1;
    scaler=affine3d([scale 0 0 0; 0 scale 0 0; 0 0 scale 0; 0 0 0 1]);
    p=transformPointsForward(scaler,p);
    translator=affine3d([eye(3,4);[0 0 abspos(1,3) 1]]);
    p=transformPointsForward(translator,p);
    % save result
    formatOut = 30;
    d=datestr(now, formatOut);
    save(strcat('large_results/',dataset_name,'/',d),'p',...
        'abspos','origin','tracks','color','s1','ang','pitch','heading',...
        'dataset_name','traj','max_error','p_bad_scale');
    
    disp(i);
end
beep;

%save('temp');