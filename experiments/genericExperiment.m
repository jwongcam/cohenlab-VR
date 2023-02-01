function code = genericExperiment
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
    if isequal(vr.exper.movementFunction, @runFromRecording)
        % read from file
        vr.fid = fopen('virmenLog.data','r');
        vr.data = fread(vr.fid,[6 inf],'double');
        vr.recordedPositions = vr.data(3:end,:);
        % transpose
        vr.recordedPositions = vr.recordedPositions';
    else
        vr.rig.initializeDaq();
        vr.fid = fopen('virmenLog.data','w');    
    end



% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
    if (vr.rig.shouldResetPosition)
        vr.position(1:2) = vr.worlds{vr.currentWorld}.startLocation;
        vr.position(4) = vr.worlds{vr.currentWorld}.startDirection;
        vr.rig.shouldResetPosition = false;
    end

    % trackLength = eval(vr.exper.variables.fullLength);
    endPosition = 105;
    if vr.position(2) > endPosition % test if the animal is at the end of the track
        vr.position(2) = 0; % set the animal’s y position to 0
        vr.dp(:) = 0; % prevent any additional movement during teleportation
    end

    
    if (vr.rig.isRecording)
        timestamp = now;
        
        % write timestamp and the x & y components of position and velocity to a file
        % using floating-point precision
        fwrite(vr.fid, [timestamp vr.rig.latestEncoderReading vr.position],'double');
        
    end
       



% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
