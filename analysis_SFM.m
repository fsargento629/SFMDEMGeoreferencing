%% load results
clear;
load('results_06_05_21_23_49','xyzPoints','camPoses');
%% plot keypoints
X=xyzPoints(:,1);
Y=xyzPoints(:,2);
Z=xyzPoints(:,3);
figure;
plot3(X,Y,Z,'o','MarkerSize',1);
hold on;
plotCamera(camPoses(1:4,:), 'Size', 2.5);
