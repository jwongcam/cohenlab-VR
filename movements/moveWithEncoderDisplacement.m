function [movement, movementType] = moveWithEncoderDisplacement(vr)
    %forward = vr.daq.inputSingleScan;

    currentEncoderReading = read(vr.rig.moveSession, 1, "OutputFormat", "Matrix");
%     
%     encoder=currentEncoderReading(:,2:3);
%     encoderDisplacement=0;
%     if encoder(1)~=vr.rig.lastencoder_dig(1)
%         if encoder(1)~=encoder(2)
%             encoderDisplacement=1;
%         else
%             encoderDisplacement=-1;
%         end
%     end

    %currentEncoderReading2 = read(vr.rig.moveSession, 2, "OutputFormat", "Matrix")
    encoderDisplacement = currentEncoderReading(1) - vr.rig.latestEncoderReading;
    vr.rig.latestEncoderReading = currentEncoderReading(1);
    
%vr.rig.latestEncoderReading
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