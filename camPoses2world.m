function [yaw, pitch, roll] = camPoses2world(camPoses)
%rotm2world return the estimated camera angles
%    % angles are as yaw pitch roll

pose=camPoses.AbsolutePose(:);
yaw=zeros(size(pose,1),1);
roll=yaw; pitch=roll;
for i=1:size(pose,1)
    % angles are as yaw pitch roll
    [yaw(i), pitch(i), roll(i)]=dcm2angle(pose(i).Rotation);
end
yaw=rad2deg(yaw); roll=rad2deg(roll);pitch=rad2deg(pitch);
end

