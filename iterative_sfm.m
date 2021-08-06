%% setup
max_error=[0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,10];
N=numel(max_error);
mean_error=zeros(1,N);
num_points=zeros(1,N);
geo_error=zeros(N,4);
rmse=zeros(1,N);
scale=zeros(1,N);
dataset_name='T4';
%% iterate
for i=1:N
    % sfm
    [p,tracks,color,errors,traj,s,ang...
        ,abspos,pitch,heading,origin] = sfm_loop(dataset_name,'SURF','KAZE',0,1,29,max_error(i));
    
    mean_error(i)=mean(errors);
    num_points(i)=size(p,1);
    scale(i)=s;
    
    % ICP and evaluate
    gridstep=30;
    [tform,~,rmse(i),~]=quickICP(p,abspos,origin,gridstep,0,0);
    [mean_xy,mean_dz]=geoEvaluate(abspos,p,tracks,dataset_name,0);
    geo_error(i,1:2)=[mean_xy,mean_dz];
    [mean_xy,mean_dz]=geoEvaluate(abspos,p,tracks,dataset_name,tform);
    geo_error(i,3:4)=[mean_xy,mean_dz];
    
    disp(i);
end

save('temp','max_error','mean_error','num_points','geo_error','rmse',...
    'scale','dataset_name');
