function [x,y,z,tri] = pcl2surf(pcl,show)


%  pass the new pcl to vector
p=pcl.Location;
%% show only REM
x=p(:,1); y=p(:,2);
z=p(:,3);
tri = delaunay(x,y);
if(show==true)
    figure;
    % Plot it with TRISURF
    trisurf(tri, x, y, z,'EdgeColor','none');
    title("REM");
    xlabel('X East (m)');ylabel('Y North (m)');zlabel('Z Elevation  (m)');
    xlim(pcl.XLimits);ylim(pcl.YLimits);
end
end

