function pix = deg2pix(deg, rigConfig)

%% written by Adam Ranson 2014
pixPerMetre = rigConfig.stimViewingModel.ScreenWidthPixels/rigConfig.stimViewingModel.ScreenWidthMetres;
meteresPerDegree = tand(1) * rigConfig.stimViewingModel.SubjectPos(3);
% convert y position in deg to pix position on screen
pix = deg * meteresPerDegree * pixPerMetre;
end