function xPix = xdeg2xpix(deg, rigConfig)
% % converts between x degrees and pix position on screen (of centre of stimulus) using stimViewingModel
%%% written by Adam Ranson 2014
if deg <= 45
    % calc x position in metres
    xMetres = tand(deg) * rigConfig.stimViewingModel.SubjectPos(3);
    % add on the animals x position
    xMetres = xMetres + rigConfig.stimViewingModel.SubjectPos(1);
    % convert to pix
    pixPerMetre = rigConfig.stimViewingModel.ScreenWidthPixels/rigConfig.stimViewingModel.ScreenWidthMetres;
    xPix = round(xMetres * pixPerMetre);
elseif deg > 45
    % calc x position in metres
    deg = deg - 90;
    xMetres = tand(deg) * rigConfig.stimViewingModel.SubjectPos(3);
    % add on the animals x position
    xMetres = xMetres + rigConfig.stimViewingModel.SubjectPos(1);
    % add on the more lateral monitor space
    xMetres = xMetres + (rigConfig.stimViewingModel.ScreenWidthMetres/2);
    % convert to pix
    pixPerMetre = rigConfig.stimViewingModel.ScreenWidthPixels/rigConfig.stimViewingModel.ScreenWidthMetres;
    xPix = round(xMetres * pixPerMetre);

else
    xPix=0;
end
end