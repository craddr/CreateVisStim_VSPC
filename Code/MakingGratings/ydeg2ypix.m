function yPix = ydeg2ypix(deg, rigConfig)

%% written by Adam Ranson 2014
% converts between y degrees and pix position on screen (of centre of stimulus) using stimViewingModel
%% old code which shows error in an unhelpful way 
if deg <= 45
    % calc y position in metres
    yMetres = tand(deg) * rigConfig.stimViewingModel.SubjectPos(3);
    % add on the animals x position
    yMetres = yMetres + rigConfig.stimViewingModel.SubjectPos(2);
    % convert to pix
    pixPerMetre = rigConfig.stimViewingModel.ScreenWidthPixels/rigConfig.stimViewingModel.ScreenWidthMetres;
    yPix = round(yMetres * pixPerMetre);
else
    msgbox('Trying to show stimulus too high/low');
    yPix=0;
    close all;
end
end