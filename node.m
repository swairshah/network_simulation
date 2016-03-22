classdef node < handle
    %NODE Source/Destination nodes in a NW
    
    properties
        id; % Node id
        load; % Packet generation probability
        nodes = {}; % List of source/destination routers known to this node
        router; % Previous/next hop router
        packet; % Packet generatated/received at the current time stamp
        cur_delay; % Delay of the current received packet
        cum_delay = 0; % Cumulative delay of the packets received
        pkt_count = 0; % Number of packets transmitted/received
    end
    
    methods (Static)
        function r_stream = rand_stream(arg)
            persistent stream;
            if nargin
                stream = arg;
            end
            r_stream = stream;
        end
    end
    
    methods
        function obj = node(id, load)
            obj.id = id;
            obj.load = load;
        end
        function obj = connect_node(obj, node)
            obj.nodes = [obj.nodes, {node}];
        end
        function obj = connect_router(obj, router)
            obj.router = router;
        end
        function obj = enqueue(obj, pkt)
            obj.packet = pkt;
        end
        function obj = send(obj, pkt)
            obj.router.enqueue(pkt);
        end
        function obj = receive(obj, cur_time)
            if ~isempty(obj.packet)
                obj.cur_delay = cur_time - obj.packet(3);
                obj.cum_delay = obj.cum_delay + obj.cur_delay;
                obj.pkt_count = obj.pkt_count + 1;
                obj.packet = [];
            else
                obj.cur_delay = 0;
            end
        end
        function pkt = generate_pkt(obj, cur_time)
            if rand(node.rand_stream) <= obj.load
                dest = randi(node.rand_stream, length(obj.nodes));
                pkt = [obj.id; obj.nodes{dest}.id; cur_time];
                obj.send(pkt);
            end
        end
        function obj = clear(obj)
            obj.packet = [];
            obj.cur_delay = 0;
            obj.cum_delay = 0;
            obj.pkt_count = 0;
        end
    end
end