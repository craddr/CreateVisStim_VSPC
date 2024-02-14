function saveData2(expID,rigConfig,globalParams,stim,allStims,trialData, timestamp_startNeuralFrames, NeuralFramesData, timeStart2p, TimeCheckNeuralFrames1, TimeCheckNeuralFrames2)

%%% written by RC 2024
% save experimental data
%localFile = data.local(expID,'psychstim.mat');
localRepositoryRoot = 'C:\Local_Repository';
animalID=data.expID2AnimalID(expID); 
savepathL=join([localRepositoryRoot,'\', animalID, '\', expID, '\', join([expID,'_psychstim.mat'])]); 
%mkdir(fileparts(savepath)); 
localFile=savepathL;
remoteRepositoryRoot='\\ar-lab-nas4\SHARE\DATA\Remote_Repository';
savepathR=join([remoteRepositoryRoot, '\', animalID, '\', expID, '\', join([expID, '_psychstim.mat'])]); 
% mkdir(fileparts(savepathR));
remoteFile=savepathR;

expData.rigConfig = rigConfig;
expData.Params = globalParams;
expData.stim = stim;
expData.trialData = trialData;
expData.startNeuralFrames= timestamp_startNeuralFrames;
expData.allStims = allStims;
expData.neuralFramesData=NeuralFramesData;
expData.timeStart2p=timeStart2p;
expData.timeCheckFrames1= TimeCheckNeuralFrames1; 
expData.timeCheckFrames2=TimeCheckNeuralFrames2;

%expData.NeuralFramesData=NeuralFramesData;

if ~exist(fileparts(localFile),'dir')
    mkdir(fileparts(localFile));
end
if ~exist(fileparts(remoteFile),'dir')
    mkdir(fileparts(remoteFile));
end

save(localFile,'expData');
save(remoteFile,'expData');


end