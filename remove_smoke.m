function [idx,new_p,new_color,new_tracks] = remove_smoke(p,color,tracks)
idx=p(:,3)<300  ;
new_p=p(idx,:);
new_color=color(idx,:);
new_tracks=tracks(idx);
end

