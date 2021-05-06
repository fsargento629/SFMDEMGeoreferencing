%% load results
clear;
load('results_06_05_21_23_49','xyzPoints');

%% get X Y Z
X=xyzPoints(:,1);
Y=xyzPoints(:,2);
Z=xyzPoints(:,3);

%% plot
plot3(X,Y,Z,'o','MarkerSize',1);