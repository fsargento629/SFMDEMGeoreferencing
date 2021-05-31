function showOrientation(angles)
%showOrientation Show yaw pitch roll in 3 different windows

figure();plot(angles(:,1));title("Relative heading (in degrees)");
figure();plot(angles(:,2));title("Relative pitch (in degrees)");
figure();plot(angles(:,3));title("Relative roll (in degrees)");
end

