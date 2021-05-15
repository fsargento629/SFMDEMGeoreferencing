function [p,t] = remove_outliers(xyzPoints,tracks,camera_pos,camera_ang)
%REMOVE_OUTLIERS 

% 1) Remove points if they are above the camera
    out_mask= xyzPoints(:,3)<camera_pos(1,3);
    p=xyzPoints(~out_mask,:);
    t=tracks(~out_mask);
    

 % 2) Remove points if they are too close to the camera in 3D
    D_3=sqrt(p(:,1).^2+p(:,2).^2+(p(:,3)-camera_pos(1,3)).^2);
    out_mask= D_3<100;
    p=p(~out_mask,:);
    t=t(~out_mask);
    
 % 3) Remove points if they are too close to the camera in 2D
    D_2=sqrt(p(:,1).^2+p(:,2).^2);
    out_mask= D_2<100;
    p=p(~out_mask,:);
    t=t(~out_mask);
    
  % 4) Remove points if they are behind the camera
  
  
  % 5) Remove points if they are too far away (in 2D)
    D_2=sqrt(p(:,1).^2+p(:,2).^2);
    out_mask= D_2>5000;
    p=p(~out_mask
    t=t(~out_mask);
    
  % 6) Remove points if they are 
end

