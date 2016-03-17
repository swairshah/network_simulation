classdef node < handle
    %NODE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id
        router % next hop router 
    end
    
    methods
        function obj = connect(obj, router)
            obj.router = router;
        end
        function pkt = pkt_generate(obj, dest, send_time)
            pkt = [obj.id; dest.id; send_time];
            obj.send(pkt);
        end
        function obj = send(obj, pkt)
            obj.router.receive(pkt);
        end
    end
end
