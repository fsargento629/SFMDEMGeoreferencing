function points = extractPoints(I,detector)
%extractPoints

if detector=="Eigen001"
    points = detectMinEigenFeatures(I, 'MinQuality', 0.001);
elseif detector=="KAZE"
    points = detectKAZEFeatures(I);
elseif detector=="ORB"
    points = detectORBFeatures(I);
elseif detector=="SURF"
    points = detectSURFFeatures(I);
elseif detector== "Eigen010"
    points = detectMinEigenFeatures(I, 'MinQuality', 0.010);
elseif detector== "Eigen100"
    points = detectMinEigenFeatures(I, 'MinQuality', 0.100);
else
    fprintf("Detector not recognized\n");
end
end

