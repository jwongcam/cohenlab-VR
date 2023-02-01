function [movement, movementType, encoderReading] = moveWithEncoder(vr)
    %forward = vr.daq.inputSingleScan;
    encoderReading = read(vr.rig.daq, 1, "OutputFormat", "Matrix");
    %position = rem(encoderPosition/50, 600);
    % disp(position);
    % disp(vr.position);
    %movement = [0,position - 300,60,0];
    %movementType = 'p';


    % turns an encoder reading into a position
    function transformedPos = transformPosition(vr, encoderReading)
        encoderCPR = 5000; % clock cycles per rotation
        encoderPosition = encoderReading - vr.rig.encoderStart;
        numTurns = encoderPosition/encoderCPR;
        circumference = eval(vr.exper.variables.distancePerTurn);
        totalDistance = numTurns * circumference;
        
        trackLength = eval(vr.exper.variables.fullLength);
        currentDisplacement = rem(totalDistance, trackLength); % mod of track length
        startingLine = -trackLength / 2;
        
        currentPosition = startingLine + currentDisplacement;
        transformedPos = [0, currentPosition, 60, 0]; % [x, y, z, view angle]
    end
    movement = transformPosition(vr, encoderReading);
    movementType = 'p';
end