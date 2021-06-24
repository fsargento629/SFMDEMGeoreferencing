function [p,tracks,reprojectionErrors,color,traj] = batch_construction_loop(...
    imds,i,batch_size,abspos,heading,pitch,... 
    intrinsics,detector,constructor,MAX_features,scale, ...
    reprojection_error_threshold)
batch_num=floor(numel(imds.Files)/batch_size);
% 0) select samples and images to use
if i<batch_num & i~=1
    samples= (i-1)*batch_size:i*batch_size;
elseif i~=1
    samples=(i-1)*batch_size:numel(imds.Files);
elseif i==1
    samples=1:batch_size;
end
[images,color_images]=getImages(imds,samples);
% 1) motion estimation
[vSet]=motion_estimation(intrinsics,images,detector,MAX_features);
fprintf("Motion estimation for loop %d done\n",i);
% 2) dense reconstruction
[xyzPoints, camPoses, reprojectionErrors,tracks]= ...
    dense_constructor_LKT(intrinsics,images,constructor,vSet);
fprintf("Dense reconstruction for loop %d done\n",i);
% 3) Coordinate transformation
[p,traj]=blender_xyz_transform(xyzPoints,...
    camPoses,abspos(samples,:),heading(samples),pitch(samples),scale);
% 4) Outlier removal
[idx,p,tracks,reprojectionErrors]=removeOutliers(...
    p,reprojectionErrors,reprojection_error_threshold,tracks);
% 5) Get color information
color=[0,0];
%color=getColor(tracks,color_images,size(p,1));
% 6) Merge results
deltaxy=(abspos(samples(1),1:2)-abspos(1,1:2));
traj(:,1:2)=traj(:,1:2) - deltaxy;
p(:,1:2)=p(:,1:2)-deltaxy;

if i>1
    for j=1:size(tracks,2)
        tracks(j).ViewIds=tracks(j).ViewIds + (i-1)*batch_size -1;
    end
end


fprintf("Loop %d done\n",i);
end

