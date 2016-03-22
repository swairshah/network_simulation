function [cum_drops, avg_delays] = sdn_simulate(duration, loads, controller, buffers, seed)
cum_drops = [];
avg_delays = [];

% Initialize the SDN
[s, t, r] = sdn_init(buffers);

% Use the same stream for all packet generation
node.rand_stream(RandStream('mt19937ar', 'Seed', seed));
for load = loads
    % Set the packet generation loads
    for i = 1:length(s)
        s{i}.load = load;
    end
    
    for time = 1:duration
        % Generate packets at the sources
        for i = 1:length(s)
            s{i}.generate_pkt(time);
        end
        
        % Make control decisions
        controller.control(r);
        
        % Process a single step of packet forwarding at every router
        sdn_step(controller, r, t, time);
    end

    % Calculate cumulative drop for this load
    cum_drop = 0;
    for i = 1:length(r)
        cum_drop = cum_drop + r{i}.cum_drop;
    end
    cum_drops = [cum_drops, cum_drop];
    % Calculate average delay for this load
    cum_delay = 0;
    pkt_count = 0;
    for i = 1:length(t)
        cum_delay = cum_delay + t{i}.cum_delay;
        pkt_count = pkt_count + t{i}.pkt_count;
    end
    avg_delay = cum_delay / pkt_count;
    avg_delays = [avg_delays, avg_delay];

    % Clear the drops & delays at nodes & routers for next load. The buffers queues are maintained though.
    for i = 1:length(r)
        r{i}.clear();
    end
    for i = 1:length(t)
        t{i}.clear();
    end
end
    
% time = duration + 1;
% for i = 1:length(r)
% % Run the steps still all the router queues are empty
%     while ~isempty(r{i}.q)
%         sdn_step(controller, r, t, time);
%         time = time + 1;
%     end
% end
end


function sdn_step(controller, r, t, time)
% Packet sent at the start of the time step
for i = length(r):-1:1
    % Process in reverse order for synchronization
    r{i}.send();
end

% Packet received at the end of the time step
for i = 3:length(r)
    % Skip R1 & R2 since they are connected to sources
    r{i}.receive();
end
for i = 1:length(t)
    t{i}.receive(time);
end

% Calculate the reward of this time step
controller.reward(r, t);
end