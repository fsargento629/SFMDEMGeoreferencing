function [scene,P_stich] = batch_stich(P,COLOR,sizes)


scene=pointCloud(P(1:sizes(1),:),'Color',COLOR(1:sizes(1),:));

% cycle all the batches:
% 1) register each of them to the scene
% 2) transform them
% 3) merge
P_stich=zeros(size(P));
P_stich(1:sizes(1),:)=P(1:sizes(1),:);
for i=2:size(sizes,1)
    %% select current pcl
    idx=sum(sizes(1:i-1))+1:sum(sizes(1:i-1))+sizes(i);
    CURR=pointCloud(P(idx,:),'Color',COLOR(idx,:));
    %% downsample
    gridSize = 5;
    fixed = pcdownsample(scene, 'gridAverage', gridSize);
    moving = pcdownsample(CURR, 'gridAverage', gridSize);
    
    %% ICP
    tform = pcregistericp(moving, fixed, 'Metric','pointToPlane','Extrapolate', true);
    ALI = pctransform(CURR,tform);
    P_stich(idx,:)=transformPointsForward(tform,P(idx,:));
    %% merge
    mergeSize = 0.001;
    scene = pcmerge(scene, ALI, mergeSize);
    
end

