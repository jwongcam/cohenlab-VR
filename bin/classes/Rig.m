classdef Rig < handle
    properties
        server
        isAcquiring
        shouldTerminate
        latestEncoderReading
        lastencoder_dig
        shouldResetPosition
        waterSession
        moveSession
        encoderStart
    end
    methods
        function obj = Rig()
            obj.server = tcpserver(5001);
            obj.isAcquiring = false;
            obj.shouldTerminate = false;
            obj.shouldResetPosition = true;
            obj.encoderStart = 0;
            obj.latestEncoderReading = 0;
            obj.lastencoder_dig=[0 0];
            configureCallback(obj.server, "terminator", @(src,evt)readFcn(obj, src,evt));
        end
        function readFcn(obj,src,~)
            vr.message = readline(src);
            if (vr.message == "start")
                currentPosition = read(obj.moveSession, 1, "OutputFormat", "Matrix");
                obj.encoderStart = currentPosition;
                obj.isAcquiring = true;
                obj.shouldResetPosition = true;
                % resetcounters(rig.daq)
                % clear rig.daq;
                % rig.daq = daq("ni");
                % addinput(rig.daq, "Dev2", 'ctr0', 'EdgeCount');
            else
                %obj.shouldTerminate = true;
                obj.isAcquiring = false;
            end
            disp(vr.message);
        end
        function initializeDaq(obj, deviceName)
            daqreset;
            obj.waterSession = daq("ni"); % background operations
            obj.moveSession = daq("ni"); % on-demand operations

            obj.waterSession.Rate = 100;
            obj.moveSession.Rate = 1000;
            addinput(obj.moveSession, deviceName, 'ctr0', 'EdgeCount');
            addinput(obj.moveSession, deviceName, 'port1/line3', 'Digital');

            addoutput(obj.moveSession, deviceName, 'port1/line0', 'Digital');
            addoutput(obj.waterSession, deviceName, 'ao0', 'Voltage');
            addinput(obj.waterSession, deviceName, 'ai3', 'Voltage');
        end
        function reward(obj)
            % for some reason, background signal output does not work
            % preload(obj.waterSession, [ones(1,100)*10 0]');
            % start(obj.waterSession);
            write(obj.waterSession, [10]);
            t = timer;
            t.StartDelay = 0.015;
            t.TimerFcn = @(~,~)write(obj.waterSession, [0]);
            start(t);
        end
        function zap(obj)
            % trigger the shutter on the rig to open for 1 second
            write(obj.moveSession, [1]);
            t = timer;
            t.StartDelay = 1;
            t.TimerFcn = @(~,~)write(obj.moveSession, [0]);
            start(t);
        end
        function delete(obj)
            try
                stop(obj.waterSession);
                stop(obj.moveSession);
            catch
                % do nothing
            end
            obj.server.delete();
        end
    end
end