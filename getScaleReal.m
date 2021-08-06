function s = getScaleReal(gps,alt,traj,dt)
% distances between each frame
d_est=traj(2:end,:)-traj(1:end-1,:);
% real distances between each frame
ttrue=getRealTraj(gps,alt);
d_true=ttrue(2:end,:)-ttrue(1:end-1,:);

% Euclidean distance between frames/gps updates
D_est=sqrt(d_est(:,1).^2+d_est(:,2).^2+d_est(:,3).^2);
D_true=sqrt(d_true(:,1).^2+d_true(:,2).^2+d_true(:,3).^2);

%% Use the median ratio to get the scale factor
s=median(D_true)*dt/median(D_est);
end

