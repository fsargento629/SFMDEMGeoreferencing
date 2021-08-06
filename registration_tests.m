%% start
% load real DEM

load("DEMs/pombal_DEM.mat"); %A,R,x_res,y_res
abspos=getRealTraj(gps,gps(:,3));

% load ICP parameters



% DEM to pcl
% make X and Y vectors
[c_origin,l_origin] = geographicToIntrinsic(R,origin(1),origin(2));
X= ((1:R.RasterSize(2))-c_origin )* x_res; % WEST-EAST
Y=( (-1:-1:-R.RasterSize(1)) + l_origin )*y_res; % NORTH-SOUTH
% convert matrix to pcl
C=size(X,2); L=size(Y,2);
XYZ=zeros(C*L,3);
i=1;
for l=1:L
    for c=1:C
        XYZ(i,:)=[X(c),Y(l),A(l,c)];
        i=i+1;
    end
end

%DEM=pointCloud(XYZ); % not using interpolation

% interpolate DEM to create a denser fixed pcl
x_inter=5;
y_inter=5;
F1 = scatteredInterpolant(XYZ(:,1),XYZ(:,2),XYZ(:,3));
[xq,yq] = ndgrid(min(XYZ(:,1)):x_inter:max(XYZ(:,1)),...
    min(XYZ(:,2)):y_inter:max(XYZ(:,2)));
vq1 = F1(xq,yq);
% turn matrices into pcl
N=numel(vq1);
XYZ=zeros(N,3);
XYZ(:,1)=reshape(xq,1,[]);
XYZ(:,2)=reshape(yq,1,[]);
XYZ(:,3)=reshape(vq1,1,[]);
DEM=pointCloud(XYZ);

%% select a relevant DEM window
% p_abs=p+[abspos(1,1:2),0];
% pcl=pcdenoise(pointCloud(p_abs));
% xmin=pcl.XLimits(1); xmax=pcl.XLimits(2);
% ymin=pcl.YLimits(1); ymax=pcl.YLimits(2);
% 
% XYZ=XYZ( XYZ(:,1)>xmin ...
%     & XYZ(:,1)<xmax,:);
% 
% XYZ=XYZ( XYZ(:,2)>ymin ...
%     & XYZ(:,2)<ymax,:);
% DEM=pointCloud(XYZ);
%% ICP
gridstep=2;

inlier_ratio=.5;
maxIterations=150;
pidw=pointCloud(p_abs);
pidw=pcdownsample(pidw,'gridAverage',gridstep);
[tform,pcl_icp,rmse]=pcregistericp(pidw,DEM,'Metric','PointToPlane',...
    'Extrapolate',true,...
    'InlierRatio',inlier_ratio,'MaxIterations',maxIterations,'Verbose',false);
% transform p and return
p_icp_abs=transformPointsForward(tform,p_abs);

% Evaluate
fprintf("------------------------\n");
disp(rmse);
points=p_icp_abs;
[xy,dz]=geo_evaluate_real(origin,points,tracks,dir,[1,2,3,4,5]);
mean(xy)

% %% phase correlation after ICP
% moving=pointCloud(p_icp_abs);   
% fixed=DEM;
% [tform,~,rmse]=pcregistercorr(moving,fixed,1000,10)
% %% CPD
% moving=pcl_icp;
% fixed=DEM;
% [tform,~,rmse]=pcregistercpd(moving,fixed,'Transform','Rigid','Verbose',true);
% %% NDT
% gridStep_dt=5;
% moving=pidw;
% fixed=DEM;
% [tform,~,rmse]= pcregisterndt(moving,fixed,gridStep_dt);



