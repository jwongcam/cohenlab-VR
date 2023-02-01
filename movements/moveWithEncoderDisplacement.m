function [movement, movementType] = moveWithEncoderDisplacement(vr)
    %forward = vr.daq.inputSingleScan;
    currentEncoderReading = read(vr.rig.daq, 1, "OutputFormat", "Matrix");
    encoderDisplacement = currentEncoderReading - vr.rig.latestEncoderReading;
    vr.rig.latestEncoderReading = currentEncoderReading;

    % convert from encoder units to VR spatial units
    function transformedDisplacement = transformDisplacement(vr, encoderDisplacement)
        encoderCPR = 5000; % clock cycles per rotation
        numTurns = encoderDisplacement/encoderCPR;
        circumference = eval(vr.exper.variables.distancePerTurn);
        totalDisplacement = numTurns * circumference;
        
        transformedDisplacement = [0, totalDisplacement, 0, 0]; % [x, y, z, view angle]
    end
    movement = transformDisplacement(vr, encoderDisplacement);
    movementType = 'd';
end