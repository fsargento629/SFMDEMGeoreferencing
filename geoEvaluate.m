function [mean_xy,mean_dz]=geoEvaluate(abspos,p,tracks,dataset_name,tform,show)
%fprintf("\n---- GeoEvaluate start ----\n\n");
%% load target pixels and true landmark locations
load(strcat('Datasets\Blender datasets\',dataset_name,'\georefer.mat'));

if isa(tform,'rigid3d')
    if show==true
        fprintf("----------POST ICP RESULTS----------\n");
    end
    p=p+[abspos(1,1:2),0];
    p=transformPointsForward(tform,p);
else
    p=p+[abspos(1,1:2),0];
    if show==true
        fprintf("----------PRE ICP RESULTS----------\n");
    end
end
%% Determine errors
N=size(id,2);
mean_xy=0;
mean_xyz=0;
mean_dz=0;
for i=1:N
    % get the closest track/pixel
    xyz_est=px2xyz(p,tracks,id(i),pxin(i,:),'10idw');
    % determine and print the errors
    D_2=sqrt( (ttrue(i,1)-xyz_est(1))^2 + (ttrue(i,2)-xyz_est(2))^2);
    D_3=sqrt(...
        (ttrue(i,1)-xyz_est(1))^2 + ...
        (ttrue(i,2)-xyz_est(2))^2 +(ttrue(i,3)-xyz_est(3))^2);
    D_Z=xyz_est(3)-ttrue(i,3);
    if show==true
        fprintf("-------Landmark %d-------\n",i);
        fprintf("True position: X=%.2f m Y=%.2f m Z=%.2f m\n", ...
            ttrue(i,1),ttrue(i,2),ttrue(i,3));
        fprintf("Estimated position: X=%.2f m Y=%.2f m Z=%.2f m\n", ...
            xyz_est(1),xyz_est(2),xyz_est(3));
        fprintf("XY error: %.2f m\n",D_2);
        fprintf("XYZ error: %.2f m\n",D_3);
        fprintf("Z error: %.2f m\n",D_Z);
    end
    % save mean results
    mean_xy=mean_xy+ D_2/N;
    mean_xyz=mean_xyz + D_3/N;
    mean_dz=mean_dz+ abs(D_Z/N);
end
if show==true
    fprintf("-------Mean error-------\n");
    fprintf("Mean XY Error: %.2f m\n",mean_xy);
    fprintf("Mean XYZ Error: %.2f m\n",mean_xyz);
    fprintf("Mean |Z| Error: %.2f m\n",mean_dz);
    fprintf("\n----GeoEvaluate end\n\n");
end
end

