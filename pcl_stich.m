%% load pcls
REF=pointCloud(P(1:sizes(1),:),'Color',COLOR(1:sizes(1),:));
CURR=pointCloud(P(sizes(1)+1:sizes(1)+1+sizes(2),:),'Color',COLOR(sizes(1)+1:sizes(1)+1+sizes(2),:));
%% downsample
gridSize = 5;
fixed = pcdownsample(REF, 'gridAverage', gridSize);
moving = pcdownsample(CURR, 'gridAverage', gridSize);

%% ICP
tform = pcregistericp(moving, fixed, 'Metric','pointToPlane','Extrapolate', true);
ALI = pctransform(CURR,tform);

%% merge
mergeSize = 0.1;
SCENE = pcmerge(REF, ALI, mergeSize);