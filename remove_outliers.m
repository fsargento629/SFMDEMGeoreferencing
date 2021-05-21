function [p,t,r] = remove_outliers(xyzPoints,tracks,reprojectionErrors,camera_pos,camera_ang,input_mask)
%REMOVE_OUTLIERS 
    p=xyzPoints;
    t=tracks;
    r=reprojectionErrors;
    if isempty(r)
        r=zeros(size(t));
    end
    
% 1) Remove points if they are above the camera 
    if input_mask(1)==1
        out_mask= xyzPoints(:,3)<camera_pos(3);
        p=xyzPoints(~out_mask,:);
        t=tracks(~out_mask);
        r=r(~out_mask);
    end
    
 % 2) Remove points if they are too close to the camera in 3D
    if input_mask(2)==1
        D_3=sqrt((p(:,1)-camera_pos(1)).^2+(p(:,2)-camera_pos(2)).^2+(p(:,3)-camera_pos(3)).^2);
        out_mask= D_3<100;
        p=p(~out_mask,:);
        t=t(~out_mask);
        r=r(~out_mask);
    end
 % 3) Remove points if they are too close to the camera in 2D
    if input_mask(3)==1
        D_2=sqrt((p(:,1)-camera_pos(1)).^2+(p(:,2)-camera_pos(2)).^2);
        out_mask= D_2<50;
        p=p(~out_mask,:);
        t=t(~out_mask);
        r=r(~out_mask);
    end
  
  % 4) Remove points if they are too far away (in 2D)
    if input_mask(4)==1
        D_2=sqrt((p(:,1)-camera_pos(1)).^2+(p(:,2)-camera_pos(2)).^2);
        out_mask= D_2>20000;
        p=p(~out_mask,:);
        t=t(~out_mask);
        r=r(~out_mask);
    end
    
    
   % 5) Remove points if their height is not in the search zone
   % this zone depends on the DEM
   if input_mask(5)==1
        out_mask= p(:,3)<-900;
        p=p(~out_mask,:);
        t=t(~out_mask);
        r=r(~out_mask);
        out_mask= p(:,3)>200;
        p=p(~out_mask,:);
        t=t(~out_mask);
        r=r(~out_mask);
   end
end

