classdef router < handle
    %ROUTER Router nodes in a NW
    
    properties
        id; % Router id
        q; % Buffer queue
        max_q; % Maximum queue size
        neighbors = {}; % List of next hop routers
        node; % Next hop node set by the central controller
        delay; % Processing delay
        cum_drop = 0; % Cumulative packet drop count at this router
        cur_drop = 0; % Numnber of packets dropped at this router in this time stamp
        next_hop % Default next_hop in absence of routing table/controller decision
    end
    
    methods
        function obj = router(id, max_q, delay)
            obj.id = id;
            obj.max_q = max_q;
            obj.delay = delay;
        end
        function obj = connect_router(obj, router)
            obj.neighbors = [obj.neighbors, {router}];
        end
        function obj = connect_node(obj, node)
            obj.node = node;
        end
        function ratio = occupancy(obj)
            ratio = size(obj.q, 2) / obj.max_q;
        end
        function obj = enqueue(obj, pkt)
            obj.q = [obj.q, pkt];
        end
        function obj = receive(obj)
            overflow = size(obj.q, 2) - obj.max_q;
            if overflow > 0
                obj.cur_drop = overflow;
                obj.cum_drop = obj.cum_drop + overflow;
                obj.q(:, obj.max_q+1:end) = []; % remove overflow pkts (columns) from q
            else
                obj.cur_drop = 0;
            end
        end
        function obj = send(obj)
            if ~isempty(obj.q)
                pkt = obj.q(:,1); % get the first (pkt) col of q
                obj.q(:,1) = []; % remove the first pkt from q
                if ~isempty(obj.node) && pkt(2) == obj.node.id
                    % deliver to destination node
                    next = obj.node;
                elseif ~isempty(obj.next_hop)
                    % forward to the next_hop router set by the contoller
                    next = obj.neighbors{obj.next_hop};
                else
                    % forward to the appropriate neighbor router connected
                    % to destination
                    dest_id = pkt(2);
                    next = obj.neighbors{1};
                    for i = 1:length(obj.neighbors)
                        neighbor = obj.neighbors{i};
                        if neighbor.id == dest_id
                            next = neighbor;
                        end
                    end
                end
                next.enqueue(pkt);
            end
        end
        function obj = clear(obj)
            obj.cur_drop = 0;
            obj.cum_drop = 0;
        end
    end
end