function s = getScaleFactor(traj,est_traj)

% get the distances covered between each view (real and estimated)
D=traj(2:end,:)-traj(1:end-1,:); 
D=sqrt(D(:,1).^2+D(:,2).^2+D(:,3).^2);
d=est_traj(2:end,:)-est_traj(1:end-1,:);
d=sqrt(d(:,1).^2+d(:,2).^2+d(:,3).^2);

s=mean(D./d);

end

