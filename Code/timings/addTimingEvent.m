 %%%%%%%%% add timing event to timeline data function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function trialData = addTimingEvent(trialData,trialNumber,eventName)

%%% written by RC 2024
    % check if any timing data has been added, if not, add a field to
    % trialData called "timing"
    if ~isfield(trialData{trialNumber},'timing')
        trialData{trialNumber}.timing = [];
    end
    %%if timing is a field, check for the timing of teh event of which
    %%we're adding, and, if doesn't exist, then add timing trialData for
    % the givben trial number, for event of interst using the
    % GetSecs RC updated from timeline/Rigbox PTBSecs usage because timeline is broken

    %% Rosie updated so we're using just GetSecs instead of the timeline stuff
    if ~isfield(trialData{trialNumber}.timing,eventName)
        trialData{trialNumber}.timing.(eventName) = GetSecs;
    else
        % this is for case where there can be multiple of some event type
        % per trial, for example

        %otherwise add the timing data as additional to past timing data
        %for this event type
        trialData{trialNumber}.timing.(eventName)(end+1)=GetSecs;
    end

end


