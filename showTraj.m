function  showTraj(t)
%SHOWTRAJ Summary of this function goes here
%   Detailed explanation goes here
figure;plot3(t(:,1),t(:,2),t(:,3),'ko--');
title("Trajectory");
xlabel("X East [m]");
ylabel("Y north [m]");
zlabel("Z altitude [m]");
end

