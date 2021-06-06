function showAllfeatures(images,tracks)
for i=1:numel(images)
    figure; imshow(images{i}); hold on;
    [px,~]=getPixelsFromTrack(tracks,i);
    scatter(px(:,1),px(:,2));
    title(strcat("Image ",int2str(i)));
end
end

