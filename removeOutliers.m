function [inliers,p,tracks,reprojectionErrors] = removeOutliers(pcl,error,reprojection_error_threshold,t)
%removeOutliers(xyzPoints) Remove outliers from point cloud
%   Detailed explanation goes here
p=pcl.Location;
%inliers=ones(size(p,1),1);
% %remove points that are too high
inliers=p(:,3)<800;
% 
% % remove points that are too low 
idx=p(:,3)>-1000;
inliers=inliers.*idx;

% remove points that are too distant (>10000 m)
D_2=sqrt(p(:,1).^2 + p(:,2).^2);
idx=D_2(:)<10000;
inliers=inliers.*idx;

% remove points if their error is above the threshold
idx=error(:)<reprojection_error_threshold;
inliers=inliers.*idx;




% compute inliers
inliers=logical(inliers);

% filter out outliers
p=p(inliers,:);
tracks=t(inliers);
reprojectionErrors=error(inliers);

% % remove the 1% highest points
% [~,idx]=maxk(p(:,3),round(size(p,1)*0.01));
% p(idx,:)=[];
% tracks(idx)=[];
% reprojectionErrors(idx)=[];
% 
% % remove the 1% lowest points
% [~,idx]=mink(p(:,3),round(size(p,1)*0.01));
% p(idx,:)=[];
% tracks(idx)=[];
% reprojectionErrors(idx)=[];

% finally, use pcdenoise to filter
[p,inliers]=pcdenoise(pointCloud(p),'NumNeighbors',5);
p=p.Location;
tracks=tracks(inliers);
reprojectionErrors=reprojectionErrors(inliers);
end

