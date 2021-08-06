%% setup
clear;
N=5; % file number
k=5; %number of samples
samples=datasample(1:N,k);
%samples=[27,14,16,23,26,23,28,2,4,2,6,30,20,7,33];
root='large_results/T11/';
scene="archeira";

%% Get the motion data for each run
ANG=zeros(k,31,3);
TRAJ=zeros(k,31,3);
j=1;
for i=samples
    load(strcat(root,int2str(i)));
    ANG(j,:,:)=ang;
    TRAJ(j,:,:)=traj;
    j=j+1;
end
%% show average and true traj, ang 
% determine averages
x=mean(TRAJ(:,:,1))+abspos(1,1);
y=mean(TRAJ(:,:,2))+abspos(1,2);
z=mean(TRAJ(:,:,3));
est_pitch=-mean(ANG(:,:,2));
est_heading=mean(ANG(:,:,1));
est_roll=mean(ANG(:,:,3));

% traj
figure; plot3(abspos(:,1),abspos(:,2),abspos(:,3),'ko--');
hold on;
plot3(x,y,z,'ro--');
title("Real and estimated trajectories (averaged)");
xlabel("X East [m]"); ylabel("Y North (m)");
zlabel("Z Up(m)");

% Pitch
figure; plot(pitch,'ko--');
hold on; plot(est_pitch,'ro--');
title("Real and estimated pitch (averaged)");
ylabel("Pitch [º]");
% Heading 
figure; plot(heading,'ko--');
hold on; plot(est_heading,'ro--');
title("Real and estimated heading (averaged)");
ylabel("Heading [º]");
% roll
figure; plot(est_roll,'ro--');
title("Estimated roll (averaged)");
ylabel("Roll [º]");