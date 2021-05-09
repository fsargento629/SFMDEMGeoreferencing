%% load small DEM
clear;
clc;
load('DEMs/uavision_DEM');
res=30;%m
z_sigma=60; %m^2
%% create a noisy point set
ppsquare=30;
pcl=zeros(ppsquare*size(small_A,1)*size(small_A,2),3);

for L=1:size(small_A,1)
    
    for C=1:size(small_A,2)
        i= ppsquare*((L-1)*size(small_A,2)+C-1)+1;
        pcl(i:i+ppsquare-1,1)=unifrnd((L-1)*res,L*res,ppsquare,1);
        pcl(i:i+ppsquare-1,2)=unifrnd((C-1)*res,C*res,ppsquare,1);
        pcl(i:i+ppsquare-1,3)=mvnrnd(small_A(L,C),z_sigma,ppsquare);
    end
    

end

%% convert noisy set to a DEM
tic;
p=2;
new_A=zeros(size(small_A));
N=size(pcl,1);
Z=zeros(L,C);
D=zeros(N,1);
for L=1:size(new_A,1)
    xc=L*res -res/2;
    for C=1:size(new_A,2)
        yc=C*res-res/2;
        X=[xc,yc];
        for i=1:N
            D(i)=norm(pcl(i,1:2)-X);
        end
        mask= D<30;
        W = 1./(D(mask).^p);
        Z(L,C)=sum(W.*pcl(mask,3))/sum(W);
        disp([L,C]);
    end    
end
toc;
figure();
surf(Z);
hold on;
surf(small_A);
RMSE=mean((abs(Z-small_A)).^2,'all');
disp(RMSE);
save('REMs/rem1.mat','Z');
