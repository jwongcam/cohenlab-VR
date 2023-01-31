classdef Rig < handle
   properties
      server
      isRecording
      shouldTerminate
      daq
      encoderStart
   end
   methods
        function obj = Rig()
            obj.server = tcpserver(5001);
            obj.isRecording = false;
            obj.shouldTerminate = false;
            obj.encoderStart = 0;
            configureCallback(obj.server, "terminator", @(src,evt)readFcn(obj, src,evt));
        end
        function readFcn(obj,src,~)
            vr.message = readline(src);
            if (vr.message == "start")
                currentPosition = read(obj.daq, 1, "OutputFormat", "Matrix");
                obj.encoderStart = currentPosition;
                obj.isRecording = true;
                % resetcounters(rig.daq)
                % clear rig.daq;
                % rig.daq = daq("ni");
                % addinput(rig.daq, "Dev2", 'ctr0', 'EdgeCount');
            else
                obj.shouldTerminate = true;
            end
            disp(vr.message);
        end
        function initializeDaq(obj)
            daqreset;
            obj.daq = daq("ni");
            addinput(obj.daq, 'Dev2', 'ctr0', 'EdgeCount');
        end
        function delete(obj)
            try
                stop(obj.daq)
            catch
                % do nothing
            end
            obj.server.delete();
        end
   end
end