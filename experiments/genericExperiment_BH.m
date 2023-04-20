function code = genericExperiment_BH
% generic   Code for a generic VR experiment
%   code = generic   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT



% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)
tt=clock; t = datetime(tt);
t.Format='yyMMddHHmm';

if isequal(vr.exper.movementFunction, @runFromRecording)
    % read from file
    
    vr.fid = fopen([char(t) 'virmenLog.data'],'r');
    vr.data = fread(vr.fid,[7 inf],'double');
    vr.recordedPositions = vr.data(3:6,:);
    % transpose
    vr.recordedPositions = vr.recordedPositions';
else
    vr.rig.initializeDaq('Dev3');
    vr.fid = fopen([char(t) 'virmenLog.data'],'w');
end



% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
endPosition = 110;
reward_pos=endPosition*0.8;
zap_pos=endPosition*0.3;
stim_lap=[10 11];

if (vr.rig.shouldResetPosition)
    vr.position(1:4) = vr.worlds{vr.currentWorld}.startLocation;
    vr.rig.shouldResetPosition = false;
    vr.position(2)=endPosition+1;
end

% trackLength = eval(vr.exper.variables.fullLength);

if vr.position(2) > endPosition % test if the animal is at the end of the track
    %vr.rig.reward();
    vr.position(2) = -15; % set the animal2s y position to 0
    vr.dp(:) = 0; % prevent any additional movement during teleportation
    if true %(vr.rig.isRecording)
        vr.trialNumber = vr.trialNumber + 1;
        vr.r_av(vr.trialNumber)=1;
        vr.s_av(vr.trialNumber)=1;
        vr.reward_pos(vr.trialNumber)=reward_pos;
        vr.zap_pos(vr.trialNumber)=0;
    end
end

if vr.position(2) <-15 % test if the animal is at the end of the track
    %vr.rig.reward();
    vr.position(2) = -15; % set the animal-s y position to 0
    vr.dp(:) = 0; % prevent any additional movement during teleportation
end

if vr.textClicked == 1 % check if textbox #1 has been clicked
     vr.rig.reward();
end

if vr.trialNumber>0
if vr.position(2)>vr.reward_pos(vr.trialNumber) && vr.r_av(vr.trialNumber)==1
    vr.rig.reward();
    vr.r_av(vr.trialNumber)=0;
 %   vr.reward_pos(vr.trialNumber+1)=0;
    vr.trialNumber
end
end

if ismember(vr.trialNumber,stim_lap)
    vr.zap_pos(vr.trialNumber)=zap_pos;
    if vr.position(2)>zap_pos &&  vr.s_av(vr.trialNumber)==1
        vr.rig.zap();
        vr.s_av(vr.trialNumber)=0;
    end
end

if (vr.rig.isRecording)
    timestamp = now;

    % write timestamp and the x & y components of position and velocity to a file
    % using floating-point precision
    fwrite(vr.fid, [timestamp vr.rig.latestEncoderReading vr.position vr.trialNumber],'double');

end




% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
if (vr.rig.isRecording)
    filepath = fileparts(which('virmenLog.data')) + "\virmenLog.data"
    writeline(vr.rig.server, filepath)
    fclose(vr.fid);

end
