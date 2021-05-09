%% load results
%clear;
%load('SFM_results/results_06_05_21_23_49','xyzPoints','camPoses');
%% plot keypoints
X=xyzPoints(:,1);
Y=xyzPoints(:,2);
Z=xyzPoints(:,3);
figure;
mask= Z<2000 & Z>-2000;
plot3(X(mask),Y(mask),Z(mask),'ko','MarkerSize',0.5);
hold on;
plotCamera(camPoses(:,:), 'Size', 0.5);
xlabel('X');
ylabel('Y');
zlabel('Z');

%% plot distances
figure;
D=sqrt(X(mask).^2+Y(mask).^2+Z(mask).^2);
plot(D);