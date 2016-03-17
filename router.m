classdef router < handle
    %ROUTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id % router id
        q % packet queue
        max_q % maximum queue size
        neighbors = [] % list of next hop routers
        delay % processing delay
        drop_count = 0
        drop_list = []
        next_hop 
    end
    
    methods
        function obj = connect(obj, another_router)
            obj.neighbors = [obj.neighbors,another_router];
            %another_router.neighbors = another_router.neighbors:obj.id;
        end
        function obj = init(obj, id, max_q, delay)
            obj.id = id;
            obj.max_q = max_q;
            obj.delay = delay;
        end
        function obj = receive(obj, pkt)
            obj.q = [obj.q, pkt];
            obj.tail_drop();
        end
        function obj = tail_drop(obj) 
            while size(obj.q, 2) > obj.max_q
                obj.drop_list = [obj.drop_list, obj.q(:, end)];
                obj.q(:,end) = []; % remove last pkt (column) from q
                obj.drop_count = obj.drop_count + 1;
            end
        end
        function obj = process(obj) % process essentially takes frist pkt of the q,
                                    % gets decision of controller and forwards
            if ~isempty(obj.neighbors)
                obj.next_hop = control_opt(obj);
                first_pkt = obj.q(:,1); % get the first (pkt) col of q
                obj.q(:,1) = []; % remove the first pkt from q
                obj.next_hop.receive(first_pkt);
            end
        end
        function obj = fwd_to_dst(obj)
            if ~isempty(obj.neighbors)
                first_pkt = obj.q(:,1); % get the first (pkt) col of q
                obj.q(:,1) = []; % remove the first pkt from q
                next_hop_id = first_pkt(2);
                for r = obj.neighbors
                    if r.id == next_hop_id
                        obj.next_hop = r;
                    else
                        obj.next_hop = obj.neighbors(1);
                    end
                end
                obj.next_hop.receive(first_pkt);
            end
            
        end
    end  
end

