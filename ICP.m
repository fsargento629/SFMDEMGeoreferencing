function [p_icp,tform,rmse] = ICP(gps,X,Y,Z,p,show)
%ICP Perform ICP on REM and transform p
load("DEMs/portugal_DEM"); 
LAT=gps(1,1); LON=gps(1,2);
A_lat= floor((R.LatitudeLimits(2)-LAT)/R.CellExtentInLatitude);
A_lon= floor((LON-R.LongitudeLimits(1))/R.CellExtentInLongitude);


x0=floor(X(1)/30); xf=floor(X(end)/30);
y0=floor(Y(1)/30); yf=floor (Y(end)/30);

DEM_X=X(1):30:X(end);
DEM_Y=Y(1):30:Y(end);
DEM_Z=A(A_lon+y0:A_lon+yf,A_lat+x0:A_lat+xf);

% Create moving pcl
L=size(Z,1);
C=size(Z,2);
moving=zeros(L*C,3);
i=1;
for l=1:L
    for c=1:C
        moving(i,:)=[X(c) Y(l) Z(l,c)];
        i=i+1;
    end
end
moving=pointCloud(moving);
% Create fixed pcl
L=size(DEM_Z,1);
C=size(DEM_Z,2);
fixed=zeros(L*C,3);
i=1;
for l=1:L
    for c=1:C
        fixed(i,:)=[DEM_X(c) DEM_Y(l) DEM_Z(l,c)];
        i=i+1;
    end
end
fixed=pointCloud(fixed);
%  register REM to small DEM
inlierRatio=1;
iter=20;
[tform,newpcl,rmse] = pcregistericp(moving,fixed,'InlierRatio',inlierRatio,...
    'MaxIterations',iter);

fprintf("RMSE from ICP: %f\n",rmse);
% transfrom p using the tform
p_icp=pctransform(pointCloud(p),tform);
p_icp=p_icp.Location;



if show==true
    %  pass the new pcl to vector
    new_p=newpcl.Location;
    %% show only REM
    idx=~isnan(new_p(:,1));
    new_p=new_p(idx,:);
    x=new_p(:,1); y=new_p(:,2);
    z=new_p(:,3);
    tri = delaunay(x,y);
    
    figure;
    % Plot it with TRISURF
    trisurf(tri, x, y, z);
    title("REM");
    xlabel('X East (m)');ylabel('Y North (m)');zlabel('Z Elevation  (m)');
    legend('Recovered DEM');
    
    %% show only DEM
    figure;
    surf(DEM_X,DEM_Y,DEM_Z);
    title("DEM");
    xlabel('X East (m)');ylabel('Y North (m)');zlabel('Z Elevation  (m)');
    %% show both
    figure;
    trisurf(tri, x, y, z, 'FaceColor','g', 'FaceAlpha',0.5, 'EdgeColor','none');
    hold on; surf(DEM_X,DEM_Y,DEM_Z, 'FaceColor','r', 'FaceAlpha',0.5, 'EdgeColor','none');
    title("DEM and REM");
    xlabel('X East (m)');ylabel('Y North (m)');zlabel('Z Elevation  (m)');
    legend('Recovered DEM','Real DEM');
end

end

