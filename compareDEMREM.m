function compareDEMREM(picp,dem)

% create triangular mesh
[xd,yd,zd,trid]=pcl2surf(dem,false);
[xr,yr,zr,trir]=pcl2surf(picp,false);

% show
figure;trisurf(trid,xd,yd,zd,'FaceAlpha',.5,'FaceColor','g',...
    'EdgeColor','none');
hold on;
trisurf(trir,xr,yr,zr,'FaceAlpha',.5,'FaceColor','r');

title("REM and DEM");
xlabel("X East [m]");ylabel("Y North [m]"); zlabel("Z Elevation [m]");
legend("DEM","REM");
xlim(picp.XLimits);
ylim(picp.YLimits);
zlim([0,400]);
end

