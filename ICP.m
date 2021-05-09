%% load REM
clear;
load('REMs/rem1.mat','Z');
load('DEMs/uavision_DEM.mat','small_A');

%% DEM parameters
res=30; %m/square;
N=size(Z,1);
M=size(Z,2);
%% turn matrix to point cloud
y=0:res:M*res-1;

xyz_m=zeros(N*M,3);
xyz_f=zeros(N*M,3);

for i=1:size(small_A,1) %iterate each line(x) of Z and small_A
    xyz_m((i-1)*N+1:i*N,:)= [(i-1)*res*ones(N,1),y(:),Z(i,:)' ];
    xyz_f((i-1)*N+1:i*N,:)= [(i-1)*res*ones(N,1),y(:),small_A(i,:)' ];
end

moving = pointCloud(xyz_m);
fixed =  pointCloud(xyz_f);
%% perform ICP
tform=pcregistericp(moving,fixed);
disp(tform.Rotation);
disp(tform.Translation)
%% show both pcls
pcshowpair(moving,fixed);