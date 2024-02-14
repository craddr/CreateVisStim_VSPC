function RosieNewlisten() 

%% written by RC 2024, based on codes written by Adam Ranson 2014, some snippets of codes written by AR directly used also
%%close all open screens frm any failed past experiments to free up GRAM
Screen('CloseAll'); 

if exist('udp2p', 'var')==1
    clear udp2p; 

end 

if exist("dq")==1
    stop(dq); 
    delete(dq);
end


%%% if udp comms is already open, close it so it doesn't fault on
%%% attempting to connect 
if exist('udpComms', 'var')==1
    clear udpComms; 
end

%%load the config data like the UDP ports, the screen info etc which was
%% make long time ago 
load("C://Code/rigConfig.mat");



%define gray to use
gray = round(255/2);
%%skip the sync tests to avoid warning messages that come with non-problematically laggy screens
Screen('Preference', 'SkipSyncTests', 1);
%%setup the screens as being gray ready for the experiment
rigConfig.w=Screen( 'OpenWindow',rigConfig.screenNumber, gray);


%%%gray texture required for later in the script, make and draw this
%%%texture ready for use later on

 grayTex = Screen('MakeTexture', rigConfig.w, ones(rigConfig.screenRect(3),rigConfig.screenRect(4))*gray);
%  grayTex2 = Screen('MakeTexture', rigConfig.w2, ones(rigConfig.screenRect(3),rigConfig.screenRect(4))*gray);
 Screen('DrawTexture', rigConfig.w, grayTex, rigConfig.screenRect, rigConfig.screenRect);
%  Screen('DrawTexture', rigConfig.w2, grayTex2, rigConfig.screenRect, rigConfig.screenRect);
 vbl = Screen('Flip', rigConfig.w);
%  vbl = Screen('Flip', rigConfig.w2);

 disp("waiting for Eyetracker PC input");

%open udpport then listen for input

udpComms=udpport("LocalPort", rigConfig.udpListenPort, "Timeout", 4000);
pause(0.5);
udpData=readline(udpComms); 
flush(udpComms);
%check for input from udpComms
if ~isempty(udpData)
    if strcmp(udpData, "TESTING")
        disp("successful udpCommunication test");
        writeline(udpComms, "OK", rigConfig.vsStimGUIIP, rigConfig.udpSendPort);
    else 
        disp("unexpected unput from udpComms, udpComm test failed"); 
        return;
    end
else 
    disp("no input from udpComms, udpComm test failed");
    return;
end


pause(0.5);
udpData=readline(udpComms); 
flush(udpComms);
if ~isempty(udpData)
    expID=udpData; 
    %%RC added 23/02/2023 
    expID=char(expID);
    writeline(udpComms, "expID received", rigConfig.vsStimGUIIP, rigConfig.udpSendPort);
else 
    disp("no expID received");
    return; 
end 
%%wait for 5 second for the stimulus parameters to be serialised and then
%%sent via udp
pause(5); 

udpData=read(udpComms, udpComms.NumBytesAvailable);
flush(udpComms);
if ~isempty(udpData)
    disp("Stim Struc Received... deserialising for use"); 
else 
    disp("Stim struc not received!!!")
    return; 
end

stim=udpData; 
stim=funcs.hlp_deserialize(stim);

%% %% convert stim data sent via UDP to MATLAB friendly format.
%%% put stim data into a callable format where we call allStim(1, n) to get
%%% the stimulus parameters (labelled) for stim n...
%%% useful later because we go stim= allStim(1,n), we can then get the sf
%%% for stimulus n by calling stim.sf by name, instead of remembering the
%%% positional data for the trail or for the parameter of interest, maybe
%%% write out later to streamline?
for iCond = 1:size(stim.stims,1)
    for iParam = 1:size(stim.params,2)
        allStims{iCond}.(stim.params{iParam})=stim.stims(iCond,iParam);
    end
end

for iCond = 1:size(stim.globalParams,2)
    globalParams.(stim.globalParams{iCond})=str2num(stim.globalParamsVals{iCond});
end


%%%start behavioural experiment

%%% start the timer and the frame acquisition 
dq=daq("ni"); 
%% set the sample rate to 1000Hz

%%for experiments between April and July 12 2023, the acqusition rate for
%%daq was set to 100, from 12/07/2023 onward, is set to 1000Hz
dq.Rate=1000; 
%% set how the data will be processed when x Frames are up (x is specified below)
% dq.ScansAvailableFcn=@(src, evt) getDatadq(src, evt);
% 
% %% set the data to get processed every 1000 Frames
% dq.ScansAvailableFcnCount=5000; 

%%add the timer and the neural frames
addinput(dq, "Dev1", "ctr0", "edgeCount");
addinput(dq, "Dev1", "ai0", "Voltage");
% 
%% add wheel movement and reward valves later if wanted

% dq1=daq("ni");
% dq1.Rate=1000;
% %Reward valves
% addoutput(dq1,'Dev1',0,'Voltage'); 
% addoutput(dq1,'Dev1',1,'Voltage'); 
% %%add rotary encoder
% dq2=daq("ni"); 
% dq2.Rate=1000;
% addinput(dq2, "Dev1","ctr1", "Position");
% dq2.EncoderType="X4";

%% start the neural frames timer and get the timestamp for when timer is started
timestamp_startNeuralFrames= GetSecs;
%start(dq, "continuous");
%%super high recording time to try to get around our issue?
start(dq, "continuous");
%start(dq, "continuous");



%%create an empty vector to write the list of stims into

stimList=[];
%% load the number of repetitions 
repetitions= globalParams.Repetitions;

%% find the number of different trials
numDiffTrials= height(stim.stims); 


%% make a list of stimuli which are pseudo-randomly ordered from 1-number of trials, and repeat this (with different pseudo random order) a number of times
for i=1:repetitions
    if i<=repetitions
        stimList=[stimList, randperm(numDiffTrials)]; 
    end 
end
totalTrials=length(stimList);
AssertOpenGL;
%%%%put the audio back in later


%%%for if we went to use auditory cues
% 
% %% auditory tones & auditory hardware
% %duration [s]
% T=0.1;
% %sample rate [Hz] Supported by SoundCard (16000,48000,96000,192000)
% Fs = 44100;
% %samples
% 
% %% %% number of samples
% N = T*Fs;
% %samples vector
% 
% %% %% vector of sample rates
% t = 0 : 1/Fs : T;
% %frequency [Hz]
% Fn = 5000;
% %signal
% % tone1 = sin(Fn*2*pi*t);+
% tone1 = [repmat(-1,[1 10]) repmat(1,[1 10]) repmat(-1,[1 10])];
% tone2 = sin(Fn*2*pi*t)*0.5;
% noise1 = rand(1,22050)*0.5;
% % audio hardware
% pahandle = PsychPortAudio('Open', -1, [], 2, 44100, 1, 0, []);
% PsychPortAudio('FillBuffer', pahandle, [0 0 0]);
% PsychPortAudio('Start', pahandle, 1,0, 1);
%%set screen to max priority level 
% Query maximum useable priorityLevel on this system:
priorityLevel=MaxPriority(rigConfig.w); %#ok<NASGU>
%%set the blend function reuired for proper anti aliasing of texrtures
%%drawn using "Draw Texture" in PTB, which we will be using... in a minute
Screen('BlendFunction', rigConfig.w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
% Screen('BlendFunction', rigConfig.w2, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
%%get the flip interval for front screen (not sure we need this, maybe edit
%%out later)
ifi=Screen('GetFlipInterval', rigConfig.w);



%%genereate stimuli from struct sent from the eyetracker PC: ie maketexture
%%for each stim using PTB but don't draw

for iStim = 1:height(stim.stims)
    stimGen{iStim} =  makeGratingData(allStims{iStim}, rigConfig);
end


%% %% generate a bunch of random intervals for time between trials during which the mouse must be stationary.
% %%The intervals are randomly generated being values between the upper and lower intervals specified in the
% %%parameters sent from eyetracker PC
% generate random q period intervals
intervalRange = globalParams.stationarytimeupper - globalParams.stationarytimelower;
qIntervals = (rand(5000,1)*intervalRange)+globalParams.stationarytimelower;



%%setup the variables for the experiment loop
%% experiment loop
trialNumber = 0;
%%include this if we want to increase probability of showing incorrect
%%trails... leave it in for now
nextTrialRep = 0;
timeStart2p=GetSecs;
timeStart=GetSecs;
%%%%change IP address correct for 2P PC
udp2p = UDPn('10.110.172.12', 9988);

udp2p.writeMsg(join(["StartAcquiring",expID]));
%% wait 5 seconds to make sure the 2p has started acquiring data
pause(5);

% NFdata=getDatadq(dq);
% NeuralFramesData=NFdata;
% NFdata=timetable2table(read(dq, "all")); 
% NeuralFramesData=NFdata;

% NFdata=read(dq, "all");
% NeuralFramesData=timetable2table(NFdata);
TimeCheckNeuralFrames1=GetSecs;
NFdata=read(dq, "all");
TimeCheckNeuralFrames2=GetSecs;
NeuralFramesData=timetable2table(NFdata);

% while(timeStart<=ExperimentStageEndTime)
while(trialNumber<=totalTrials)
    trialNumber=trialNumber+1;
    stimID=stimList(trialNumber); 
    disp(join(["starting trial number:", num2str(trialNumber), "(stim type:", num2str(stimID), ")"])); 
%%then store to a struct the stimID, the stimulus parameters
    trialData{trialNumber}.stimID=stimID;
    trialData{trialNumber}.stimAttributes = allStims{stimID};



    %%make a "timing event" for the start of the first trial

        trialData = addTimingEvent(trialData,trialNumber,'StartTrial');

            %% Variable ITI period starts
    itiEnd = GetSecs + qIntervals(trialNumber);
    %%get a wheel reading 
    
%     WheelPosStart=getWheel(daqSessionWheel);


    trialData = addTimingEvent(trialData,trialNumber,'StartIti');
    %%you need to put in here that if the mouse has moved the wheel beyond threshold during the iti/Q
    %%period, then the time resets, and this is recorded in struct
    %%"trialData"
   while(GetSecs<itiEnd)
% %         WheelPos=getWheel(daqSessionWheel);
% 
% %         if WheelPos>=abs(globalParams.ballthreshold) 
% %             trialData=addTimingEvent(trialData, trialNumber, 'Qbroken');
% %             %%add sound here if wanted
% % 
% %             %%restard iti/q period 
% %             itiEnd= GetSecs+ itiEnd;
% %             WheelPosStart=getWheel(daqSessionWheel);
% %         
% % 
       end 
%     end
    trialData = addTimingEvent(trialData,trialNumber,'EndIti');
%     trialData{trialNumber}.timeIti = trialData{trialNumber}.timing.EndQIti-trialData{trialNumber}.timing.StartQIti;

    %%animal has now been stationary for long enough

    trialData = addTimingEvent(trialData,trialNumber,'StimulusStart');
    drifttimeStart=GetSecs;
    drifttimeEnd=GetSecs+allStims{stimID}.drifttime;
%     WheelPosStart=getWheel(daqSessionWheel);
        waitframes=1;
    %while(GetSecs<respWindowEnd)
    while(GetSecs<drifttimeEnd)
%% RC commented out to stop screen flicker 23/02/2023
%         drawnow;
                % visual stimulus
%         driftTime = GetSecs - trialData{trialNumber}.timing.StimulusStart;
driftTime=GetSecs-drifttimeStart;
        xoffset = mod(driftTime*stimGen{stimID}.shiftpersec,stimGen{stimID}.p);
        srcRect = floor([xoffset 0 xoffset + stimGen{stimID}.srcRect(1) stimGen{stimID}.srcRect(2)]);
        srcRectMask = [0 0 stimGen{stimID}.srcRect];

        Screen('DrawTexture', stimGen{stimID}.screenRef, stimGen{stimID}.gratingtex, srcRect, stimGen{stimID}.dstRect, stimGen{stimID}.ori);
        Screen('DrawTexture', stimGen{stimID}.screenRef, stimGen{stimID}.masktex, srcRectMask, stimGen{stimID}.dstRect, stimGen{stimID}.ori);
%             if WheelPos>=abs(globalParams.ballthreshold)
%             trialData=addTimingEvent(trialData, trialNumber, 'Turn');
%             WheelPosStart=getWheel(daqSessionWheel);
%             trialData{trialNumber}.correct=1;
%             giveRewardhalfsec(daqSessionReward);
%             break;
%             end
        vbl = Screen('Flip', rigConfig.w, vbl + (waitframes - 0.5) * ifi);
%         vbl = Screen('Flip', rigConfig.w2, vbl + (waitframes - 0.5) * ifi);
%% get the wheel position
%         WheelPos=getWheel(daqSessionWheel);
%%if is above threshold, then add events to trial data, reward and stop
%%showing stim

    end

                % show gray
            Screen('DrawTexture', rigConfig.w, grayTex, rigConfig.screenRect, rigConfig.screenRect);
%             Screen('DrawTexture', rigConfig.w2, grayTex2, rigConfig.screenRect, rigConfig.screenRect);
            vbl = Screen('Flip', rigConfig.w, vbl + (waitframes - 0.5) * ifi);
%         vbl = Screen('Flip', rigConfig.w2, vbl + (waitframes - 0.5) * ifi);
        %%if it wasn't correct then add this 
%         if ~isfield(trialData{trialNumber}, 'correct')
%             trialData{trialNumber}.correct=0;
%         end 
%         trialData=addTimingEvent(trialData,trialNumber,'ResponseEnd');
%         trialData=addTimingEvent(trialData,trialNumber, 'ClearingScreen');

trialData=addTimingEvent(trialData, trialNumber, 'StimulusEnd');

        %% RC commented out 22/02/2023
% %%set the screen back to gray
%         Screen('DrawTexture', rigConfig.w, grayTex, rigConfig.screenRect, rigConfig.screenRect);
%         Screen('DrawTexture', rigConfig.w2, grayTex2, rigConfig.screenRect, rigConfig.screenRect);
%         vbl = Screen('Flip', rigConfig.w);
%         vbl = Screen('Flip', rigConfig.w2);

%  NFdata= timetable2table(read(dq, "all"));
% % if trialNumber==1
% %     NeuralFramesData=NFdata;
% % else
% NeuralFramesData=vertcat(NeuralFramesData, NFdata); 
% % end
% % 
% %         %%save recent trial data 
% saveData(stim.expID,rigConfig,globalParams,stim,stimList,trialData, timestamp_startNeuralFrames, NeuralFramesData);

%% doing NF with functions
% NFdata=getDatadq(dq);
% NeuralFramesData=vertcat(NeuralFramesData, NFdata);
% saveData(stim.expID,rigConfig,globalParams,stim,stimList,trialData, timestamp_startNeuralFrames, NeuralFramesData);

% NFdata=read(dq, "all");
% NeuralFramesData=timetable2table(NFdata);
% %NeuralFramesData=vertcat(NeuralFramesData, NeuralFramesData2);
% saveData(stim.expID,rigConfig,globalParams,stim,stimList,trialData, timestamp_startNeuralFrames, NeuralFramesData, timeStart2p);
%%if the trial number has reached the maximum number of stims we decided to
%%show the animal this session, then stop everything
        if(trialNumber+1)>totalTrials
            break; 
        end

        timeStart=GetSecs;

end


% %% get the NeuralFrames data 
%  NFdata= timetable2table(read(dq, "all"));
% % NFdata=getDatadq(dq);
% 
% 
% % NeuralFramesData= vertcat(NeuralFramesData, NFdata); 
% NeuralFramesData=NFdata;

% NFdata=read(dq, "all");
% NeuralFramesData=timetable2table(NFdata);
%NeuralFramesData=vertcat(NeuralFramesData, NeuralFramesData2);
%saveData(stim.expID,rigConfig,globalParams,stim,stimList,trialData, timestamp_startNeuralFrames, NeuralFramesData, timeStart2p);


% if trialNumber==1
%     NeuralFramesData=NFdata;
% else
%     NeuralFramesData=vertcat(NeuralFramesData, NFdata); 
% end

% NeuralFramesData=dq.ScansAvailableFcn;

 %NeuralFramesData=NFdata;
%%final save data
saveData2(expID,rigConfig,globalParams,stim,stimList,trialData, timestamp_startNeuralFrames, NeuralFramesData, timeStart2p, TimeCheckNeuralFrames1, TimeCheckNeuralFrames2);
%%tell the 2p to stop acquiring data
udp2p.writeMsg("StopAcquiring");
pause(5);
%%stop the Neural Frames timer daq
stop(dq);
%%disconnect from the 2p PC 
udp2p.disconnect();

%%wait for everytrhing to save and all tones/ stims to finish
% pause(5);
%%close the audio port
% PsychPortAudio('Close',pahandle);

%close the daq Sessions 
% daqSessionReward.release;
% daqSessionWheel.release;
% %%tell the Eye tracker PC that we're done here.
% writeline(udpComms,"ExperimentComplete", rigConfig.vsStimGUIIP, rigConfig.udpSendPort);

% tl.stop;

%%tell the Eye tracker PC that we're done here.
writeline(udpComms,"ExperimentComplete", rigConfig.vsStimGUIIP, rigConfig.udpSendPort);

end
%%function for gettign the neural frames data every  x frames (x specified
%%by ScansAvailableFcnCount in the code body.
% function NFdata=getDatadq(src, ~)
% NFdata=timetable2table(read(src, src.ScansAvailableFcnCount));
% 
% % if exist("NeuralFramesData", "var")
% %     NeuralFramesData= vertcat(NeuralFramesData, NFdata); 
% % else 
% %     NeuralFramesData=NFdata;
% % end 
% end

