function [p,t] = batch2global(pcl,traj,gps1,gps2,alt1,alt2)
%BATCH2GLOBAL Transforms a trajectory and point cloud to the global
%reference frame


% Determine x y and z distances
origin = [gps1(1), gps1(2), alt1];
[dx,dy] = latlon2local(gps2(1),gps2(2),alt2,origin);

% Create and apply translation matrix
tform=affine3d([eye(3,4);[dx dy 0 1]]);
p=pctransform(pcl,tform);

% Convert trajectory to world coordinates
t=traj+[dx dy 0];
end

