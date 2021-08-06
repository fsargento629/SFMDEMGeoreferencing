%% setup
clear;
N=20; % file number
k=10; %number of samples
samples=datasample(1:N,k);
%samples=[27,14,16,23,26,23,28,2,4,2,6,30,20,7,33];
root='large_results/V1/';
scene="Vila_real";
%% iterate all sfm results and dtermine raw errors and noisy errors
raw_ers=zeros(k,4); % xy dz xy dz 
noisy_ers=zeros(k,4);
count=1;
for i=samples
    load(strcat(root,int2str(i)));
    % no noise
    raw_ers(count,:)=test_tolerance... 
        (origin,dataset_name,tracks,abspos,p,0,0,0,0,scene);
    % with noise
    noisy_ers(count,:)=test_tolerance... 
        (origin,dataset_name,tracks,abspos,p,normrnd(0,10),normrnd(0,10)...
        ,normrnd(0,1),normrnd(0,1),scene);
    disp(count)
    count=count+1;
end
beep; 
% save res 
%save("ICP_optimization/icpres_50_03",'noisy_ers','samples','raw_ers');
fprintf("Saved\n");
%% show raw results
% figure; scatter(raw_ers(:,1),raw_ers(:,2));
% hold on; scatter(raw_ers(:,3),raw_ers(:,4));
% xlabel("Horizontal error [m]");
% ylabel("Vertical error [m]");
% hold on;
% for i=1:size(raw_ers,1)
%     plot([raw_ers(i,1),raw_ers(i,3)],[raw_ers(i,2),raw_ers(i,4)],'k');
% end
% legend("Before ICP","After ICP");
% title("Georeferencing errors before and after ICP with no noise");
% show results with noise
figure; scatter(noisy_ers(:,1),noisy_ers(:,2));
hold on; scatter(noisy_ers(:,3),noisy_ers(:,4));
xlabel("Horizontal error [m]");
ylabel("Vertical error [m]");
hold on;
for i=1:size(noisy_ers,1)
    plot([noisy_ers(i,1),noisy_ers(i,3)],[noisy_ers(i,2),noisy_ers(i,4)],'k');
end
legend("Before ICP","After ICP");
title("Georeferencing errors before and after ICP with noise");