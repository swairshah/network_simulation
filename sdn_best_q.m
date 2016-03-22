function best_q = sdn_best_q(duration, N, batch, load, buffers, action_size, epsilon_step)
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
cols = ceil((N+1)/rows);

load = loads;
if size(loads, 2) == 1
	load = ones(1, batch) * loads;
end
best_mean = -Inf;
best_q = [];
drops = [];
delays = [];
figure('name', 'Q Candidates');
for n = 1:N
	% Create a new Q-controller
    q = control_q(buffers(1:4), action_size, epsilon_step, dec_seed);

	% Run the simulations
	[drop, delay] = sdn_simulate(duration, load, q, buffers, pkt_seed);
	drops = [drops, drop];
	delays = [delays, delay];

	if mean(q.cum_reward) > best_mean
		best_q = q;
	end

	subplot(rows, cols, n);
	plot(q.cum_reward);
	title(strcat('Candidate-', n));
	xlabel('Time(i)');
	ylabel('Reward(points)');
	if n == 1
		title_epsilon = strcat(', Epsilon-1/', epsilon_step);
		title(strcat('Same packets', title_epsilon));
	end
end

x_value = loads;
x_label = 'Load(p)';
if size(loads, 2) == 1
	x_value = 1:batch;
	x_label = 'Time(batch)';
end

subplot(rows, cols, N+1);
title('Q-learner');
xlabel(x_label);
yyaxis left;
plot(x_value, drops);
ylabel('Drop(count)');
yyaxis right;
plot(x_value, delays);
ylabel('Delay(ms)');
end