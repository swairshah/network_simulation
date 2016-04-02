function best_q = sdn_best_q(duration, N, batch, loads, buffers, action_size, epsilon_step)
% Use the same seed for all packet generation
pkt_seed = randseed;
% Use the same seed for all random decisions
dec_seed = randseed;

switch 1
    case N <= 3
        rows = 1;
    case N <= 9
        rows = 2;
    case N <= 17
        rows = 3;
    otherwise
        rows = 4;
end
cols = ceil((N)/rows);

load = loads;
if size(loads, 2) == 1
    load = ones(1, batch) * loads;
end
best_mean = -Inf;
best_q = [];
figure('name', 'Q Candidates');
for n = 1:N
    % Create a new Q-controller
    q = control_q(buffers(1:4), action_size, epsilon_step, dec_seed);
    
    % Run the simulations
    sdn_simulate(duration, load, q, buffers, pkt_seed);
    
    cur_mean = mean(q.cum_reward);
    if cur_mean > best_mean
        best_q = q;
        best_mean = cur_mean;
    end
    
    subplot(rows, cols, n);
    plot(q.cum_reward);
    title(strcat('Candidate-', num2str(n)));
    xlabel('Time');
    ylabel('Reward');
    if n == 1
        title(sprintf('Same packets, epsilon-1/%d', 1/epsilon_step));
    end
end

savefig(sprintf('[%s], %d-%d.fig', sprintf('%d,', buffers), sample_size, replay_size));
end