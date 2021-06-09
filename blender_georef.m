 %% load results
 clear;clc;
 load("SFM_results/T1_SURF_Eigen_08_06_19_36");
 
%% Use the absolute position of the first view to translate p
pabs=p+[abspos(1,1:2),0];
picpabs=picp+[abspos(1,1:2),0];
 
 %% choose the pixel
 id=1; % view index
 figure; imshow(images{id});
 pxin=ginput(1);

 %% find the closest pixel to it that has a track
[px,small_tracks,small_p]=getPixelsFromTrack(tracks,id,p);
D=sqrt((pxin(1)-px(:,1)).^2 + (pxin(2)-px(:,2)).^2);
[D_min,idx]=mink(D,1);


 
 %% Insert blender coordinates of target
ttrue=[-5.60,606,322];

%% Determine error before ICP
p_testabs=small_p(idx,:)+[abspos(1,1:2),0];
D_2=sqrt( (ttrue(1)-p_testabs(1))^2 + (ttrue(2)-p_testabs(2))^2);
D_3=sqrt(...
    (ttrue(1)-p_testabs(1))^2 + ... 
    (ttrue(2)-p_testabs(2))^2 +(ttrue(3)-p_testabs(3))^2);
fprintf("-------Before ICP-------\n");
fprintf("True position: X=%.2f Y=%.2f Z=%.2f\n", ... 
    ttrue(1),ttrue(2),ttrue(3));
fprintf("Estimated position: X=%.2f Y=%.2f Z=%.2f\n", ... 
    p_testabs(1),p_testabs(2),p_testabs(3));
fprintf("XY error: %.2f\n",D_2);
fprintf("XYZ error: %.2f\n",D_3);
%% Determine error after ICP
p_testabs=picpabs(idx,:);
D_2=sqrt( (ttrue(1)-p_testabs(1))^2 + (ttrue(2)-p_testabs(2))^2);
D_3=sqrt(...
    (ttrue(1)-p_testabs(1))^2 + ... 
    (ttrue(2)-p_testabs(2))^2 +(ttrue(3)-p_testabs(3))^2);
fprintf("-------After ICP-------\n");
fprintf("True position: X=%.2f Y=%.2f Z=%.2f\n", ... 
    ttrue(1),ttrue(2),ttrue(3));
fprintf("Estimated position: X=%.2f Y=%.2f Z=%.2f\n", ... 
    p_testabs(1),p_testabs(2),p_testabs(3));
fprintf("XY error: %.2f\n",D_2);
fprintf("XYZ error: %.2f\n",D_3);

