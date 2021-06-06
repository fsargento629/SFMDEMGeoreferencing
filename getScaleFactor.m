function s = getScaleFactor(traj,est_traj,pcloud,metric)

if metric=="distanceRatio"
    % get the distances covered between each view (real and estimated)
    D=traj(2:end,:)-traj(1:end-1,:);
    D=sqrt(D(:,1).^2+D(:,2).^2+D(:,3).^2);
    d=est_traj(2:end,:)-est_traj(1:end-1,:);
    d=sqrt(d(:,1).^2+d(:,2).^2+d(:,3).^2);
    s=mean(D./d);
    
elseif metric=="meanHeight"
    % A-> 210m
    Z=210;%metres
    z=mean(pcloud.Location(:,3));
    s= (Z+traj(1,3))/z;
    
elseif metric=="medianHeight"
    Z=200;%metres (A)
    z=median(pcloud.Location(:,3));
    s= (Z+traj(1,3))/z;
end

disp(s);
end

