function [new_ang] = compareAngles(ang,heading,pitch)
%compareAngles Draw the estimated and real angles

new_ang= ang+ [heading(1)  ,pitch(1),0];

% show heading
figure; plot(heading,'ro--'); hold on;
plot(new_ang(:,1),'ko--');
title("True and estimated heading");
xlabel("Frame number");
ylabel("Heading [º]");
legend("True heading","Estimated heading");


% show pitch
figure; plot(pitch,'ro--'); hold on;
plot(new_ang(:,2),'ko--');
title("True and estimated pitch");
xlabel("Frame number");
ylabel("Pitch [º]");
legend("True pitch","Estimated pitch");

end

