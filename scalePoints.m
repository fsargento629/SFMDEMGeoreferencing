function [points] = scalePoints(p,scale,alt)
% apply test scale to p
translator=affine3d([eye(3,4);[0 0 -alt 1]]);
points=transformPointsForward(translator,p);
scaler=affine3d([scale 0 0 0; 0 scale 0 0; 0 0 scale 0; 0 0 0 1]);
points=transformPointsForward(scaler,points);
translator=affine3d([eye(3,4);[0 0 alt 1]]);
points=transformPointsForward(translator,points);
end

