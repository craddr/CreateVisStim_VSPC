classdef UDPn < handle    

%% Written by BA and RC 2024.
    properties
        udpObject;
        remoteHost;
        remotePort;
    end
    
    methods
        function obj = UDPn(remotehost,remoteport)
            obj.udpObject = udpport("IPV4");
            
            configureTerminator(obj.udpObject,"CR/LF");
         
            
            
            
            
            
            
            
            configureCallback(obj.udpObject,"terminator", @obj.DatagramReceivedFcn);
            obj.remoteHost = remotehost;
            obj.remotePort = remoteport;
        end

        function writeMsg(obj, msg)
            try
                writeline(obj.udpObject,msg,obj.remoteHost, obj.remotePort);
            catch ex
                disp(ex.message);
            end
        end

%         function DatagramReceivedFcn(obj,~,datagram)
%             try
%                 data = readline(obj.udpObject);
%                 disp(data);
%                 return;
%             catch ex
%                 disp(ex.message);
%             end
%         end

        function data=DatagramReceivedFcn(obj,~,~)
            try
                data = readline(obj.udpObject);
                disp(data);
            catch ex
                disp(ex.message);
            end
        end

        function disconnect(obj)
            flush(obj.udpObject,"output");
            clear('obj.udpObject');
        end



        function sendData(obj, ~,~)
            try
                data=read(obj.udpObject);
                disp(data);
            catch ex
                disp(ex.message)
            end
        end

        function ready=awaitReady(obj,timeout)

            startTime=GetSecs; 
            while((GetSecs-startTime)<timeout)
                Data= obj.DatagramReceivedFcn; 
                if Data=="READY"
                    ready=1;
                    disp("ConfirmationReceived"); 
                    return;
                else 
                    disp("No ready confirmation given within timeout period");
                end 
            end 
        end 

                   




        on


        





    end
end
