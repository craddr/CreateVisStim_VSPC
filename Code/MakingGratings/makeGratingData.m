function gratingData= makeGratingData(stim, rigConfig)

%% adapted by RC 2024, codes largely written by Adam Ranson 2014
% convert stimulus properties to pixels (from degrees)

pixPerDegree = deg2pix(1, rigConfig);

%% %% get sf in cycles per pixel (not per degree)
stim.sf         = (stim.sf)/pixPerDegree;
stim.xsize      = 2*ceil(deg2pix((stim.xsize), rigConfig)/2)+1;
stim.ysize      = 2*ceil(deg2pix((stim.ysize), rigConfig)/2)+1;

if stim.xsize>1600
    stim.xsize=1600;
        stim.xpos=0;
else 
    stim.xpos       = round(xdeg2xpix((stim.xpos), rigConfig)-(stim.xsize/2));
end

if stim.ysize>900
    stim.ysize=900;
    stim.ypos=0;
else 
    stim.ypos       = round(ydeg2ypix((stim.ypos), rigConfig)-(stim.ysize/2));
end

% stim.xpos       = round(xdeg2xpix((stim.xpos), rigConfig)-(stim.xsize/2));
% stim.ypos       = round(ydeg2ypix((stim.ypos), rigConfig)-(stim.ysize/2));
stim.ori        = round((stim.ori));

% Define Half-Size of the grating image.
stim.texSize=stim.xsize/2;

%make new gray, white and black based on the contrast of the stimulus
white=round((255/2)+(0.5*255*(stim.contrast)));
black=round((255/2)-(0.5*255*(stim.contrast)));
gray=round((white+black)/2);
inc=white-gray;
p=ceil(1/stim.sf);
stim.sfr=stim.sf*2*pi;
visiblesize=stim.xsize+1;
x = meshgrid(-stim.texSize:stim.texSize + p, 1);
%%%make the gratings for x coordinates the whole way across the size of the
%%%stim + extra for the drift that happens before the refresh... I think
grating=gray + inc*cos(stim.sfr*x);


%%%% if you want to do a square waveform instead of a sin waveofrm (block
%%%% colours for bars instead of graduation in a sin wave 

if (stim.sqwaveform) ==1
    % make square wave
    grating(grating>=black+((white-black)*(stim.duty)))=white;
    grating(grating<black+((white-black)*(stim.duty)))=black;
end

if (stim.shape) == 1
    %%a sine wave grating with no gaussian window to soften the edges of
    %%the stimulus against the gray background
    mask=ones(stim.ysize,stim.xsize,2)*gray;
    elipMask = (Ellipse((stim.xsize/2),(stim.ysize/2))==0)*255;
    mask(:, :, 2)=elipMask;
elseif (stim.shape) == 2
    % gabor window
    %%This is Adam's code, and I think he meant "gabor patch"...
    % aka sine wave grating throgh a gaussian window to soften the edges
    windowsSize = length(x);
    mask=ones(windowsSize,windowsSize,2)*gray;
    % [xgab,ygab]=meshgrid(-1*stim.texSize:1*stim.texSize,-1*stim.texSize:1*stim.texSize);
    [xgab,ygab]=meshgrid(-1*windowsSize/2:1*windowsSize/2,-1*windowsSize/2:1*windowsSize/2);
    elipMask = 255 * (1 - exp(-((xgab/90).^2)-((ygab/90).^2)));
    elipMask = elipMask(1:windowsSize,1:windowsSize);
    mask(:, :, 2)=elipMask;
elseif (stim.shape)==3
    %%gabor patch 
    %windowsSize = length(x);
    mask=ones(stim.ysize,stim.xsize,2)*gray;
    % [xgab,ygab]=meshgrid(-1*stim.texSize:1*stim.texSize,-1*stim.texSize:1*stim.texSize);
    [xgab,ygab]=meshgrid(-1*stim.ysize/2:1*stim.xsize/2,-1*stim.ysize/2:1*stim.xsize/2);
    elipMask = 255 * (1 - exp(-((xgab/90).^2)-((ygab/90).^2)));
    elipMask = elipMask(1:stim.ysize,1:stim.xsize);
    mask(:, :, 2)=elipMask;
elseif (stim.shape)==4
    %% fullscreen with gaborwindow
    %% where gabor window is the size of the screen in pix
    Screenheight=stim.ysize; 
    Screenwidth=stim.xsize;
    mask=ones(Screenheight, Screenwidth,2)*gray;
        [xgab,ygab]=meshgrid(-1*Screenwidth/2:1*Screenwidth/2,-1*Screenheight/2:1*Screenheight/2);
           % elipMask = 255 * (1 - exp(-((xgab/90).^2)-((ygab/90).^2)));
           elipMask = 255 * (1 - exp(-((xgab/(Screenwidth/4)).^2)-((ygab/(Screenheight/4)).^2)));
    elipMask = elipMask(1:Screenheight,1:Screenwidth);
    mask(:, :, 2)=elipMask;

else  
    %%no mask- just show taht stimulus full screen
    mask=ones(stim.ysize,stim.xsize,2)*gray;
    elipMask = (Ellipse((stim.xsize/2),(stim.ysize/2))==0)*0;
    mask(:, :, 2)=elipMask;
end

%%as the stimulus is always shown on the front screen: 
    gratingtex=Screen('MakeTexture', rigConfig.w, grating);
    masktex=Screen('MakeTexture', rigConfig.w, mask);
    dstRect=round([stim.xpos stim.ypos stim.xpos+stim.xsize stim.ypos+stim.ysize]);


%% changed by RC 13/06/2023- change back if required
screenRef=rigConfig.w;
    %% %% p= pixels per cycle (our stimulus sf is measured in cycles per pixel)
    %%note that we're using the unrounded value for pixels per cycle
    %%instead of the rounded value we used to generate the matrix from
    %%which to draw the stimulus 
p=1/stim.sf;  % pixels/cycle
%% cycles per second * pixels per cycle. ie pixles per second
shiftpersec= (stim.tf) * p;

% prepare output structure
gratingData.gratingtex = gratingtex;
gratingData.masktex = masktex;
gratingData.p = p;
gratingData.shiftpersec = shiftpersec;
gratingData.srcRect = [stim.xsize stim.ysize];
gratingData.dstRect = dstRect;
gratingData.texSize = stim.texSize;
gratingData.screenRef = screenRef;
gratingData.ori = stim.ori;
gratingData.p = p;
end
