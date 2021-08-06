function [rmses,best_p,best_rmse,best_scale,best_tform,best_i] = iterative_ICP_real(p,origin,scene)
alt=origin(3);
% create return vars
scale=0.8:0.02:1.1;
rmses=zeros(size(scale));
% ICP for scale=1
[best_rmse,best_tform,best_p] = ICP(p,[0,0,0],origin(1:2),scene,'real');
best_scale=1;
best_i=find(scale==1);
rmses(scale==1)=best_rmse;
% iterate over all scales to find the best one
for i=1:numel(scale)
    if scale(i)==1
        continue;
    end
    % apply test scale to p
    translator=affine3d([eye(3,4);[0 0 -alt 1]]);
    new_p=transformPointsForward(translator,p);
    scaler=affine3d([scale(i) 0 0 0; 0 scale(i) 0 0; 0 0 scale(i) 0; 0 0 0 1]);
    new_p=transformPointsForward(scaler,new_p);
    translator=affine3d([eye(3,4);[0 0 alt 1]]);
    new_p=transformPointsForward(translator,new_p);
    % do icp
    [rmses(i),tform,p_icp_abs] = ICP(new_p,[0,0,0],origin(1:2),scene,'real');
    
    % save results if it is an improvement
    if rmses(i)<best_rmse
        best_rmse=rmses(i);
        best_i=i;
        best_tform=tform;
        best_scale=scale(i);
        best_p=p_icp_abs;
    end
    disp(i);
end
end

