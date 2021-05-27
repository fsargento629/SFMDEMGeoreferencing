function [v,R] = cam2world(vector,pitch,heading,scale)
%transform return rotated vector v, using the vector in camera coordinates
%   Detailed explanation goes here

% pitch
axang = deg2rad(-(90+pitch+180));
rotm1 = axang2rotm([1 0 0 axang]);
% heading
axang = deg2rad(heading);
rotm2 = axang2rotm([0 0 1 axang]);

% apply rotation to vector
R=rotm1*rotm2;
v=vector*R;
% scale
v=scale*v;


% figure;scatter3(vector(1),vector(2),vector(3),'r*');
% hold on;scatter3(v(1),v(2),v(3),'g*');
% xlabel('X East (m)');
% ylabel('Y North (m)');
% zlabel('Z height from sea level (m)');
end

