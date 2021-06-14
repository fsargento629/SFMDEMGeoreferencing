function geoEvaluate(abspos,p,tracks,dataset_name,tform)
fprintf("\n---- GeoEvaluate start ----\n\n");
%% load target pixels and true landmark locations
load(strcat('Datasets\Blender datasets\archeira\',dataset_name,'\georefer.mat'));

if isa(tform,'rigid3d')
    fprintf("----------POST ICP RESULTS----------\n");
    p=p+[abspos(1,1:2),0];
    p=transformPointsForward(tform,p);
else
    p=p+[abspos(1,1:2),0];
    fprintf("----------PRE ICP RESULTS----------\n");
end
%% Determine errors 
N=size(id,2);
mean_xy=0;
mean_xyz=0;
mean_dz=0;
for i=1:N
    % get the closest track/pixel
    [px,~,small_p]=getPixelsFromTrack(tracks,id(i),p);
    D=sqrt((pxin(i,1)-px(:,1)).^2 + (pxin(i,2)-px(:,2)).^2);
    [~,idx]=mink(D,1);
    % dtermine and print the errors
    p_testabs=small_p(idx,:);
    D_2=sqrt( (ttrue(i,1)-p_testabs(1))^2 + (ttrue(i,2)-p_testabs(2))^2);
    D_3=sqrt(...
        (ttrue(i,1)-p_testabs(1))^2 + ...
        (ttrue(i,2)-p_testabs(2))^2 +(ttrue(i,3)-p_testabs(3))^2);
    D_Z=p_testabs(3)-ttrue(i,3);
    fprintf("-------Landmark %d-------\n",i);
    fprintf("True position: X=%.2f m Y=%.2f m Z=%.2f m\n", ...
        ttrue(i,1),ttrue(i,2),ttrue(i,3));
    fprintf("Estimated position: X=%.2f m Y=%.2f m Z=%.2f m\n", ...
        p_testabs(1),p_testabs(2),p_testabs(3));
    fprintf("XY error: %.2f m\n",D_2);
    fprintf("XYZ error: %.2f m\n",D_3);
    fprintf("Z error: %.2f m\n",D_Z);
    
    % save mean results
    mean_xy=mean_xy+ D_2/N;
    mean_xyz=mean_xyz + D_3/N;
    mean_dz=mean_dz+ abs(D_Z/N);
end
fprintf("-------Mean error-------\n");
fprintf("Mean XY Error: %.2f m\n",mean_xy);
fprintf("Mean XYZ Error: %.2f m\n",mean_xyz);
fprintf("Mean |Z| Error: %.2f m\n",mean_dz);
fprintf("\n----GeoEvaluate end\n\n");
end

